// Copyright 2017-2020 the u-root Authors. All rights reserved
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// Command bootpxe implements PXE-based booting followed by local booting.

package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"net"
	"strings"
	"time"

	"github.com/insomniacslk/dhcp/dhcpv4"
	"github.com/insomniacslk/dhcp/iana"
	"github.com/u-root/u-root/pkg/boot"
	"github.com/u-root/u-root/pkg/boot/bootcmd"
	"github.com/u-root/u-root/pkg/boot/localboot"
	"github.com/u-root/u-root/pkg/boot/menu"
	"github.com/u-root/u-root/pkg/boot/netboot"
	"github.com/u-root/u-root/pkg/cmdline"
	"github.com/u-root/u-root/pkg/curl"
	"github.com/u-root/u-root/pkg/dhclient"
	"github.com/u-root/u-root/pkg/ipmi"
	"github.com/u-root/u-root/pkg/ipmi/ocp"
	"github.com/u-root/u-root/pkg/mount"
	"github.com/u-root/u-root/pkg/mount/block"
	"github.com/u-root/u-root/pkg/sh"
	"github.com/u-root/u-root/pkg/ulog"
)

var (
	ifName      = "^e.*"
	noLoad      = flag.Bool("no-load", false, "get DHCP response, print chosen boot configuration, but do not download + exec it")
	noExec      = flag.Bool("no-exec", false, "download boot configuration, but do not exec it")
	noNetConfig = flag.Bool("no-net-config", false, "get DHCP response, but do not apply the network config it to the kernel interface")
	skipBonded  = flag.Bool("skip-bonded", false, "Skip NICs that have already been added to a bond")
	verbose     = flag.Bool("v", false, "Verbose output")
	ipv4        = flag.Bool("ipv4", true, "use IPV4")
	ipv6        = flag.Bool("ipv6", true, "use IPV6")
	cmdAppend   = flag.String("cmd", "", "Kernel command to append for each image")
	bootfile    = flag.String("file", "", "Boot file name (default tftp) or full URI to use instead of DHCP.")
	server      = flag.String("server", "0.0.0.0", "Server IP (Requires -file for effect)")
)

const (
	dhcpTimeout = 5 * time.Second
	dhcpTries   = 3
)

func NetbootImages(ifaceNames string) ([]boot.OSImage, error) {
	filteredIfs, err := dhclient.Interfaces(ifaceNames)
	if err != nil {
		return nil, err
	}

	if *skipBonded {
		filteredIfs = dhclient.FilterBondedInterfaces(filteredIfs, *verbose)
	}

	ctx, cancel := context.WithTimeout(context.Background(), (1<<dhcpTries)*dhcpTimeout)
	defer cancel()
	var modifiers []dhcpv4.Modifier
	option93 := dhcpv4.OptClientArch(iana.EFI_RISCV64_HTTP)
	modifiers = append(modifiers, dhcpv4.WithOption(option93))
	c := dhclient.Config{
		Timeout:    dhcpTimeout,
		Retries:    dhcpTries,
		Modifiers4: modifiers,
	}
	if *verbose {
		c.LogLevel = dhclient.LogSummary
	}
	r := dhclient.SendRequests(ctx, filteredIfs, *ipv4, *ipv6, c, 30*time.Second)

	for {
		select {
		case <-ctx.Done():
			return nil, ctx.Err()

		case result, ok := <-r:
			if !ok {
				return nil, fmt.Errorf("nothing bootable found, all interfaces are configured or timed out")
			}
			iname := result.Interface.Attrs().Name
			if result.Err != nil {
				log.Printf("Could not configure %s for %s: %v", iname, result.Protocol, result.Err)
				continue
			}

			if *noNetConfig {
				log.Printf("Skipping configuring %s with lease %s", iname, result.Lease)
			} else if err := result.Lease.Configure(); err != nil {
				log.Printf("Failed to configure lease %s: %v", result.Lease, err)
			}

			imgs, err := netboot.BootImages(context.Background(), ulog.Log, curl.DefaultSchemes, result.Lease)
			if err != nil {
				log.Printf("Failed to boot lease %v: %v", result.Lease, err)
				continue
			}

			return imgs, nil
		}
	}
}

func newManualLease() (dhclient.Lease, error) {
	filteredIfs, err := dhclient.Interfaces(ifName)
	if err != nil {
		return nil, err
	}

	d, err := dhcpv4.New()
	if err != nil {
		return nil, err
	}

	d.BootFileName = *bootfile
	d.ServerIPAddr = net.ParseIP(*server)

	return dhclient.NewPacket4(filteredIfs[0], d), nil
}

func dumpNetDebugInfo() {
	log.Println("Dump debug info of network status")
	commands := []string{"ip link", "ip addr", "ip route show table all", "ip -6 route show table all", "ip neigh"}
	for _, cmd := range commands {
		cmds := strings.Split(cmd, " ")
		name := cmds[0]
		args := cmds[1:]
		sh.RunWithLogs(name, args...)
	}
}

func updateBootCmdline(cl string) string {
	f := cmdline.NewUpdateFilter(*cmdAppend, []string{}, []string{})
	return f.Update(cl)
}

func localBoot() {
	log.Printf("local_boot....")
	blockDevs, err := block.GetBlockDevices()
	if err != nil {
		log.Fatal("No available block devices to boot from")
	}

	blockDevs = blockDevs.FilterZeroSize()

	log.Printf("Booting from the following block devices: %v", blockDevs)

	var l ulog.Logger = ulog.Null
	if *verbose {
		l = ulog.Log
	}
	mountPool := &mount.Pool{}
	images, err := localboot.Localboot(l, blockDevs, mountPool)
	if err != nil {
		log.Fatal(err)
	}
	for _, img := range images {
		if li, ok := img.(*boot.LinuxImage); ok {
			li.Cmdline = updateBootCmdline(li.Cmdline)
		}
	}

	menuEntries := menu.OSImages(*verbose, images...)
	menuEntries = append(menuEntries, menu.Reboot{})
	menuEntries = append(menuEntries, menu.StartShell{})

	bootcmd.ShowMenuAndBoot(menuEntries, mountPool, *noLoad, *noExec)
}

func getBootOrderViaIPMI() (byte, error) {
	var bootType byte
	i, err := ipmi.Open(0)
	if err != nil {
		log.Printf("Failed to open ipmi device %v, watchdog may still be running", err)
		return ocp.LOCAL_BOOT, err
	}
	defer i.Close()

	bootType, err = ocp.GetBootOrder(i)

	if err != nil {
		log.Printf("Failed to get bootOrder!")
		return ocp.LOCAL_BOOT, err
	} else {
		log.Printf("bootType %d.", bootType)
		return bootType, nil
	}
}

func setLocalBootViaIPMI() error {
	i, err := ipmi.Open(0)
	if err != nil {
		log.Printf("Failed to open ipmi device %v, watchdog may still be running", err)
		return err
	}
	defer i.Close()
	err = ocp.SetLocalBootOrder(i)
	if err != nil {
		log.Printf("Failed to set local_boot!")
		return err
	}
	log.Printf("Set local_boot!")
	return nil
}

func main() {
	bootType, err := getBootOrderViaIPMI()
	if err != nil {
		localBoot()
	} else {
		if bootType == ocp.NETWORK_BOOT {
			//pxe_boot
			log.Printf("Try to boot from network.")
			flag.Parse()
			if len(flag.Args()) > 1 {
				log.Fatalf("Only one regexp-style argument is allowed, e.g.: " + ifName)
			}
			if len(flag.Args()) > 0 {
				ifName = flag.Args()[0]
			}

			var images []boot.OSImage
			var err error
			maxRetries := 2
			for attempts := 0; attempts < maxRetries; attempts++ {
				if *bootfile == "" {
					images, err = NetbootImages(ifName)
					if err != nil {
						log.Printf("PXE boot failed: %v", err)
						dumpNetDebugInfo()
					} else {
						break
					}
				} else {
					log.Printf("Skipping DHCP for manual target..")
					var l dhclient.Lease
					l, err = newManualLease()
					if err == nil {
						images, err = netboot.BootImages(context.Background(), ulog.Log, curl.DefaultSchemes, l)
						break
					} else {
						log.Printf("PXE Manual boot failed: %v", err)
					}
				}
			}
			setLocalBootViaIPMI()
			if err == nil {
				for _, img := range images {
					img.Edit(func(cmdline string) string {
						return cmdline + " " + *cmdAppend
					})
				}

				menuEntries := menu.OSImages(*verbose, images...)
				menuEntries = append(menuEntries, menu.Reboot{})
				menuEntries = append(menuEntries, menu.StartShell{})
				bootcmd.ShowMenuAndBoot(menuEntries, nil, *noLoad, *noExec)
			} else {
				localBoot()
			}
		} else {
			localBoot()
		}
	}

}
