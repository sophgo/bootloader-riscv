# 1.3.0_2025-06-09

## sophgo-2260
branch: master \
tag: NA \
commit: 66e064675c0487e0505e265cb02059a9d26f6b7f

+ No update

## bootloader-riscv
branch: master \
tag: NA \
commit: c84d2a7a23a3bb48d0e29844d09a15e74ea77cc4

+ No update

## zsbl
branch: sg2044-rel-v2.1.4 \
tag: sg2044-rel-v2.1.4 \
commit: 54c5dfc3d394d71d54470b62c25a74c8fd894075

+ Add I2C3 node in DTS for the RTC in SG2044 socket board.

## opensbi
branch: sg2044-1.6-v20250516 \
tag: SG2044_OpenSBI-1.6.0_v20250516 \
commit: 78f021d24823bd84c47cc2b68e99921fcfe14139

+ No update

## linux-riscv
branch: sg2044-rel-6.12.32 \
tag: SG2044_Linux-6.12.32_v20250609 \
commit: 235bad8cb1f072912e2d38740822b252ba8852a5

+ Update to 6.12.32

## sophgo-edk2
branch: release-sg2044-20250609 \
tag: sg2044_sophgo-edk2_20250609 \
commit: cd17b8be72f66a9046912bdf7c0a22370f122791

+ SG2044Pkg: Support ACPI only
+ SG2044: Add SMBIOS tables based on BRS Spec
+ SG2044: Fixed password related bugs in BIOS Menu
+ efi: Fixbug, zero memory which is allocated by EDK2

# 1.2.0_2025-05-16

## sophgo-2260
branch: master \
tag: NA \
commit: 66e064675c0487e0505e265cb02059a9d26f6b7f

+ Auto set VDDR voltage depends on different chip conner and work modes
+ Change default DDR size from 64GiB to 128GiB
+ Slow down CPU and CCN frequency and auto adaptive frequency depends on different chip conner and work modes

## bootloader-riscv
branch: master \
tag: NA \
commit: fe7367e21f354e1aff6c0b951708045e62fc99ac

+ Sign firmware by default
+ Build EDK2 as release instead of debug

## zsbl
branch: sg2044-rel-v2.1.3 \
tag: sg2044-rel-v2.1.3 \
commit: f7b3966692ccd68113f73bfd7de773323942e3f0

+ Support SoC mode
+ Support parse efi variables which stored by EDK2
+ Slow down SPIFMC clock from 25MHz to 12.5MHz
+ Add conf.ini files for SRA3-40 and SRA3-40-8
+ Support secure boot
+ Support DDR auto adaptive
+ Support DVFS
+ Support FDT overlay
+ Fix some bugs

## opensbi
branch: sg2044-1.6-v20250516 \
tag: SG2044_OpenSBI-1.6.0_v20250516 \
commit: 78f021d24823bd84c47cc2b68e99921fcfe14139

+ Support DVFS
+ Fix warning message of timer in boot phase

## linux-riscv
branch: sg2044-rel-6.12.28 \
tag: SG2044_Linux-6.12.28_v20250516 \
commit: 9e47841899041661caaba1903187a93ef1c58872

+ Update to 6.12.28
+ sophgo/tpu: Add head verify
+ sophgo/ddrc: Add error check

## sophgo-edk2
branch: release-sg2044-20250516 \
tag: sg2044_sophgo-edk2_20250516 \
commit: 1871c7fb8fa7316d6004332cf82e68081b63ed86

+ SG2044:Add MCU firmware update function for EVB
+ Sophgo/SG2044: Update SMBIOS Type 0 information
+ Sophgo/SG2044Pkg: Update reserve memory size range
+ SG2044: Support F9 reset default value for BootTimeout and ReserveMemory
+ SG2044: Workaround: Remove duplicated boot options
+ SG2044: Remove unnecessary debug log when release
+ Implement IPMI communication over UART between BIOS and BMC
+ SG2044/AcpiPlatformDxe: Fixbug, Wrong PCIe controller initialized
+ NorFlashDxe: Add a function to lock/unlock all blocks
+ Sophgo/Library: Add verification function for PK in SG2044 secure boot
+ Feature: acpi support video subsys
+ SpifmcDxe: Modify SetupDevice() function
+ Sophgo/Library: fix boot option duplication and boot order updates
+ peiDxe: Add APEI support for SG2044 platform
+ Sophgo/SG2044Pkg: Support dynamic modify frequency
+ NorFlashDxe: Add a function to lock/unlock all blocks
+ Add xt25q512f support

# 1.1.0_2025-01-21

## [zsbl(sg2044-rel-v1.0.2)](https://github.com/sophgo/zsbl/tree/sg2044-rel-v1.0.2)
+ Add fdt dump function

+ Support PCIe node parsing dynamically

+ Three external contribution:

  > lib/sgcfg: allow file load from fs root

  > SG2044: set initramfs in dtb

  > SG2044: allow to set bootargs

## [opensbi(sg2044-v1.6.0)](https://github.com/sophgo/opensbi/tree/sg2044-v1.6.0)
+ No new commits.

## [linux-riscv(sg2044-rel-6.12.10)](https://github.com/sophgo/linux-riscv/tree/sg2044-rel-6.12.10)
+ Rebase on upstream v6.12.10

+ Support two efuse controllers

+ PCI/ACPI: Increase SG2044 max PCI hosts to 10

+ Add ACPI support for 1G Ethernet

+ perf: Do not allow invalid raw event config

+ Enable kernel configs: CONFIG_ACPI_DEBUGGER，CONFIG_ACPI_DEBUGGER_USER，CONFIG_ACPI_FPDT，CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT，CONFIG_DEBUG_INFO_BTF

## [sophgo-edk2(release-sg2044-20250121)](https://github.com/sophgo/sophgo-edk2/tree/release-sg2044-20250121)
+ BIOS Menu：support load default, power off and reset; update getting firmware version number and firmware build date by reading Nor Flash; update getting DDR size by reading eFuse

+ ACPI: support power button; support 1G ETH; support FPDT; refine DSDT, delete unnecessary info; support dynamically update DSDT; ACPI boot at default

+ Driver/Library/Application: fix 1G ETH driver TX and RX DMA issue, known issue: packet loss; support eFuse Library; support eFuse Application

# 1.0.0_2025-01-09

## [bootloader-riscv(master)](https://github.com/sophgo/bootloader-riscv/tree/master)

+ change ramdisk get ip from /proc/sgdrv/vethip (@xiangwen.jiang in [8b7976ee00ccb06](https://github.com/sophgo/bootloader-riscv/commit/8b7976ee00ccb06) at 2025-01-08 09:45:46)
    > Signed-off-by: xiangwen.jiang &lt;xiangwen.jiang@sophgo.com&gt;

+ scripts: modify BM1690 boot file address. (@dong.yang in [1491742c520fa58](https://github.com/sophgo/bootloader-riscv/commit/1491742c520fa58) at 2025-01-03 08:04:42)
    > Signed-off-by: dong.yang &lt;dong.yang@sophgo.com&gt;

+ pcie mode rp use zsbl.bin (@tingzhu.wang@sophgo.com in [05231d991d1a43e](https://github.com/sophgo/bootloader-riscv/commit/05231d991d1a43e) at 2024-12-26 07:14:38)
    > Signed-off-by: tingzhu.wang@sophgo.com &lt;tingzhu.wang@sophgo.com&gt;

+ change the address of ip (@tingzhu.wang@sophgo.com in [070a738f8a53632](https://github.com/sophgo/bootloader-riscv/commit/070a738f8a53632) at 2024-12-26 02:49:09)
    > Signed-off-by: tingzhu.wang@sophgo.com &lt;tingzhu.wang@sophgo.com&gt;

+ SG2042:Release:V1.1.0 (@chunzhi.lin in [efb9cfed97e59e1](https://github.com/sophgo/bootloader-riscv/commit/efb9cfed97e59e1) at 2024-12-25 02:57:56)
    > Signed-off-by: chunzhi.lin &lt;chunzhi.lin@sophgo.com&gt;

+ Add pxe boot. (@zhaohui-yan in [93245269b0655de](https://github.com/sophgo/bootloader-riscv/commit/93245269b0655de) at 2024-12-24 04:12:01)

+ script:sg2042:: avoid repeated umount (@sharim in [9ea83bac2605cb0](https://github.com/sophgo/bootloader-riscv/commit/9ea83bac2605cb0) at 2024-12-20 02:47:32)
    > Signed-off-by: sharim &lt;sharim.pyi@gmail.com&gt;

+ script:sg2042::fix fedora image&#x27;s rootfs path (@sharim in [68a3a36bdf83bda](https://github.com/sophgo/bootloader-riscv/commit/68a3a36bdf83bda) at 2024-12-19 03:17:49)
    > Signed-off-by: sharim &lt;sharim.pyi@gmail.com&gt;

+ script:sg2042::modify behavior of &#x60;mkdir&#x60; and &#x60;umount&#x60; (@sharim in [350798ff66abb4b](https://github.com/sophgo/bootloader-riscv/commit/350798ff66abb4b) at 2024-12-18 12:36:15)
    > 1. add &#x27;-p&#x27; to &#x60;mkdir&#x60; to avoid &quot;create existed directory&quot; error
    > 2. add &#x27;-R&#x27; to &#x60;umount&#x60; to auto umount rootfs recursively
    > Signed-off-by: sharim &lt;sharim.pyi@gmail.com&gt;

+ scripts: fix some bugs (@JianHang Wu in [191c4efbe36733e](https://github.com/sophgo/bootloader-riscv/commit/191c4efbe36733e) at 2024-12-13 10:19:02)
    > Signed-off-by: JianHang Wu &lt;jianhang.wu@sophgo.com&gt;

+ Scripts:change the default offset and fix a bug (@JianHang Wu in [95c8a85d5c9600d](https://github.com/sophgo/bootloader-riscv/commit/95c8a85d5c9600d) at 2024-12-09 22:19:51)
    > Signed-off-by: JianHang Wu &lt;jianhang.wu@sophgo.com&gt;

+ Scripts:do some optimizations. (@JianHang Wu in [1cdf8237a80d7be](https://github.com/sophgo/bootloader-riscv/commit/1cdf8237a80d7be) at 2024-12-09 09:35:12)
    > -add overlap checking, error reporting, info print functionality in gen_firmware_xml.c.
    > -remove some redundant files(gen_spi_flash.c and gen_sg2044r_spi_flash.c,etc).
    > If you need to add new board-level firmware, please follow the example to add the corresponding information at the head of gen_firmware_xml.c file. Additionally, add or modify the relevant functions in envsetup.sh (including specifying the release-note path and macros, etc).
    > Signed-off-by: JianHang Wu &lt;jianhang.wu@sophgo.com&gt;

+ script: modify fw path for bm1690. (@dong.yang in [fe1796a58b3f17f](https://github.com/sophgo/bootloader-riscv/commit/fe1796a58b3f17f) at 2024-12-05 03:35:33)
    > Signed-off-by: dong.yang &lt;dong.yang@sophgo.com&gt;

+ scripts: refine mango and sg2044 build scripts (@Jingyu Li in [828af44ad55f38b](https://github.com/sophgo/bootloader-riscv/commit/828af44ad55f38b) at 2024-12-03 12:26:43)
    > - Moved the DTB copy earlier to avoid issues with kernel Makefile version or
    > rpmbuild tool version inconsistencies.
    > - FSBL source code is not publicly available; the daily build system updates
    > the SG2044 binary at a fixed link and will automatically download it if
    > missing locally.
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ scripts: fix build_rv_euler_kernel bug (@Jingyu Li in [a052f452e8c1211](https://github.com/sophgo/bootloader-riscv/commit/a052f452e8c1211) at 2024-11-29 06:18:22)
    > Different versions of the Linux kernel have varying build paths.
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ scripts: refine build process (@Jingyu Li in [4e5a4f9fe786b09](https://github.com/sophgo/bootloader-riscv/commit/4e5a4f9fe786b09) at 2024-11-28 08:00:23)
    > - Add DTB generation to build_rv_ubuntu/euler_kernel.
    > - Only copy the DTB file corresponding to the specified $CHIP into the firmware
    > directory.
    > - For SG2044, Remove the LinuxBoot binaries when build_rv_*_image
    > process; remove the LinuxBoot build process when build_rv_firmware.
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ modify the packaging scripts and add packaging support for SG2044 firmware (@wujianhang in [a60c5e4a38a7463](https://github.com/sophgo/bootloader-riscv/commit/a60c5e4a38a7463) at 2024-11-27 13:48:45)

+ scripts: revert build_rv_pcie_zsbl for BM1690. (@dong.yang in [7d5fa90c035fbc0](https://github.com/sophgo/bootloader-riscv/commit/7d5fa90c035fbc0) at 2024-11-27 13:04:09)
    > Now we use PCIe zsbl config for BM1690 in sg2260-pld branch,
    > so keep this cmd until BM1690 switch to zsbl master branch.
    > Signed-off-by: dong.yang &lt;dong.yang@sophgo.com&gt;

+ scripts: remove checkout op when building EDK II (@Jingyu Li in [fc17795954f4b29](https://github.com/sophgo/bootloader-riscv/commit/fc17795954f4b29) at 2024-11-27 10:02:39)
    > In the daily-build system, the checkout operation synchronizes remote changes
    > stored in the refs/remotes/* space. However, if we also perform a checkout
    > during the local build process, the local changes in the refs/heads/* space can
    > lead to synchronization issues, including potential version rollbacks.
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ scripts: Restore rpm build directory to default directory (@Xiaoguang Xing in [e39fa86943a382b](https://github.com/sophgo/bootloader-riscv/commit/e39fa86943a382b) at 2024-11-25 13:48:33)
    > Signed-off-by: Xiaoguang Xing &lt;xiaoguang.xing@sophgo.com&gt;

+ scripts: fix rpm&#x27;s builddir when linux ver &gt;&#x3D; 6.10 (@sharim in [874948fdc477ec7](https://github.com/sophgo/bootloader-riscv/commit/874948fdc477ec7) at 2024-11-25 09:59:57)
    > Signed-off-by: sharim &lt;sharim.pyi@gmail.com&gt;

## [zsbl(master)](https://github.com/sophgo/zsbl/tree/master)

+ bm1690: cli_loop(0) will cause zsbl into cmdline. (@dong.yang in [779440bd7d73f96](https://github.com/sophgo/zsbl/commit/779440bd7d73f96) at 2025-01-04 09:03:55)
    > In PCIe mode, zsbl should directly jump to the next level to
    > continue execution.
    > Signed-off-by: dong.yang &lt;dong.yang@sophgo.com&gt;

+ support getopt series functions (@Chao Wei in [d8a5994f48a23ff](https://github.com/sophgo/zsbl/commit/d8a5994f48a23ff) at 2024-12-31 15:01:47)

+ SG2044: remove c920 csr log on boot (@Chao Wei in [57dff4918865a5b](https://github.com/sophgo/zsbl/commit/57dff4918865a5b) at 2024-12-31 14:33:32)
    > add a command lscsr instead.
    > press j, enter console, then execute lscsr command

+ remove outdated efuse driver (@Chao Wei in [b6f2fd576b40d15](https://github.com/sophgo/zsbl/commit/b6f2fd576b40d15) at 2024-12-31 14:25:55)

+ add more device list commands (@Chao Wei in [66d995632cb323e](https://github.com/sophgo/zsbl/commit/66d995632cb323e) at 2024-12-31 14:23:08)

+ add command, list boot devices (@Chao Wei in [07753bc184d6f57](https://github.com/sophgo/zsbl/commit/07753bc184d6f57) at 2024-12-31 14:15:08)
    > lsbdev, list boot devices

+ add command, list all platform devices (@Chao Wei in [ce547abc97a4253](https://github.com/sophgo/zsbl/commit/ce547abc97a4253) at 2024-12-31 14:11:53)
    > lspdev, list platform devices

+ add console (@Chao Wei in [679cb81f20fbe19](https://github.com/sophgo/zsbl/commit/679cb81f20fbe19) at 2024-12-31 14:11:53)

+ SG2044: Auto generate memory information (@Chao Wei in [0e3bba0a8cf5071](https://github.com/sophgo/zsbl/commit/0e3bba0a8cf5071) at 2024-12-30 04:25:48)
    > Auto generate memory information by eFuse data

+ modify memory node in dtb automatically (@Chao Wei in [fa0fbce42bd0152](https://github.com/sophgo/zsbl/commit/fa0fbce42bd0152) at 2024-12-27 14:23:14)

+ follow device naming convension (@Chao Wei in [fe702a41a2562b2](https://github.com/sophgo/zsbl/commit/fe702a41a2562b2) at 2024-12-27 14:20:59)

+ add alias property in device (@Chao Wei in [a82264d8946a516](https://github.com/sophgo/zsbl/commit/a82264d8946a516) at 2024-12-27 14:20:59)

+ add nvmem device model (@Chao Wei in [8f9f41cabfdd7c6](https://github.com/sophgo/zsbl/commit/8f9f41cabfdd7c6) at 2024-12-27 14:20:59)
    > add nvmem device model
    > add its first device driver, sophgo efuse

+ SG2044: support geting dram information from efuse (@Chao Wei in [572f47fc5740d09](https://github.com/sophgo/zsbl/commit/572f47fc5740d09) at 2024-12-27 14:20:59)

+ fix conflict macro definitions (@Chao Wei in [4ec7ed9e1725cb6](https://github.com/sophgo/zsbl/commit/4ec7ed9e1725cb6) at 2024-12-27 14:20:59)

+ using alias to index boot devices (@Chao Wei in [455a9160aaf5885](https://github.com/sophgo/zsbl/commit/455a9160aaf5885) at 2024-12-27 14:20:59)

+ change tp memory layout of pcie mode (@tingzhu.wang@sophgo.com in [e287bbc15974dc7](https://github.com/sophgo/zsbl/commit/e287bbc15974dc7) at 2024-12-26 02:26:41)
    > Signed-off-by: tingzhu.wang@sophgo.com &lt;tingzhu.wang@sophgo.com&gt;

+ Modify the value of DDR data-rate in conf.ini (@lin fei in [fc1ca4037f53799](https://github.com/sophgo/zsbl/commit/fc1ca4037f53799) at 2024-12-25 12:51:56)
    > Signed-off-by: lin peng &lt;peng.lin@sophgo.com&gt;

+ Modify the conf.ini content according to SMBIOS specifications (@lin fei in [ae1bd24a1b30eac](https://github.com/sophgo/zsbl/commit/ae1bd24a1b30eac) at 2024-12-25 12:38:45)
    > - Remove the chassis-related content.
    > - Update the values for DDR, CPU, and cache sections according to SMBIOS specifications.
    > - Standardize the casing (uppercase/lowercase) in conf.ini.
    > Signed-off-by: lin peng &lt;peng.lin@sophgo.com&gt;

+ SG2044: Fix footer &quot;[eof]&quot; not found in EDK II phase (@Jingyu Li in [a3b608caf8edb15](https://github.com/sophgo/zsbl/commit/a3b608caf8edb15) at 2024-12-19 22:53:19)
    > Set the NULL character after the footer rather than before.
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ SG2044: Remove debug information of mtd device (@Chao Wei in [d47989c20cc9fc6](https://github.com/sophgo/zsbl/commit/d47989c20cc9fc6) at 2024-12-17 08:36:41)

+ SG2042: Support parseing MAC from conf.ini (@Chao Wei in [1864a4ade785fd9](https://github.com/sophgo/zsbl/commit/1864a4ade785fd9) at 2024-12-13 15:27:08)

+ SG2044: Support parseing MAC from conf.ini (@Chao Wei in [46fdc55a77ba9e1](https://github.com/sophgo/zsbl/commit/46fdc55a77ba9e1) at 2024-12-13 15:20:55)

+ Add lib to support ethernet MAC operations (@Chao Wei in [c20883b669d7d71](https://github.com/sophgo/zsbl/commit/c20883b669d7d71) at 2024-12-13 15:20:06)

+ SG2044: Support SPI NOR flash boot (@Chao Wei in [1d7b025be539b1a](https://github.com/sophgo/zsbl/commit/1d7b025be539b1a) at 2024-12-13 13:28:07)
    > 1. Add SOPHGO SPIFMC driver
    > 2. Change flash file table from 0x60_0000 to 0x8000

+ SG2044: Load config file to a conventional address (@Chao Wei in [a7a46291660399b](https://github.com/sophgo/zsbl/commit/a7a46291660399b) at 2024-12-12 13:56:59)
    > Instead of loading conf.ini to an allocated address,
    > load conf.ini to a conventional address, aka 0x89000000.
    > EDK2 will get conf.ini from there and getting informations about
    > SoC and boards.

+ Modify l2 cache size to 2MiB in sg2044 evb conf.ini (@lin fei in [f4aa049e9883272](https://github.com/sophgo/zsbl/commit/f4aa049e9883272) at 2024-12-05 08:58:26)
    > Signed-off-by: lin fei &lt;peng.lin@sophgo.com&gt;

+ Add sg2044 evb conf.ini in zsbl Repository (@lin fei in [22fd2846a4b1d4e](https://github.com/sophgo/zsbl/commit/22fd2846a4b1d4e) at 2024-12-04 07:24:05)
    > Signed-off-by: lin peng &lt;peng.lin@sophgo.com&gt;

+ qemu riscv64 virt works (@Chao Wei in [7fb853c748aedbc](https://github.com/sophgo/zsbl/commit/7fb853c748aedbc) at 2024-11-27 12:56:46)

+ Remove unused ARM code (@Chao Wei in [a2b7d8d84bf9635](https://github.com/sophgo/zsbl/commit/a2b7d8d84bf9635) at 2024-11-27 12:23:39)

+ Add serial device driver model (@Chao Wei in [c5842115d6de303](https://github.com/sophgo/zsbl/commit/c5842115d6de303) at 2024-11-27 11:56:38)

+ SG2042: Fixbug, wrong dtb used (@Chao Wei in [14568dc124fa9a3](https://github.com/sophgo/zsbl/commit/14568dc124fa9a3) at 2024-11-26 12:11:37)
    > 1. Setup dtb names after config init
    > 2. Add prefix &quot;riscv64&quot; in sgfat lib
    > 3. Setup boot device priority before loading any files

## [opensbi(sg2044-dev)](https://github.com/sophgo/opensbi/tree/sg2044-dev)

+ makefile: remove linker garbage collection print (@Xiaoguang Xing in [748d7041081b049](https://github.com/sophgo/opensbi/commit/748d7041081b049) at 2024-12-25 06:16:07)
    > See commmit 0171cfc(&quot;Makefile: enable --gc-sections&quot;).
    > Signed-off-by: Xiaoguang Xing &lt;xiaoguang.xing@sophgo.com&gt;

+ lib: fix warning message of timer in boot phase (@haijiao.liu in [3de9421b0211a27](https://github.com/sophgo/opensbi/commit/3de9421b0211a27) at 2024-12-25 01:42:05)
    > Optimize the reset driver to prevent the use of the timer function
    > before the timer driver initialization is completed, which resloves
    > the following warning messages:
    > sbi_timer_delay_loop: called without timer device
    > Signed-off-by: haijiao.liu &lt;haijiao.liu@sophgo.com&gt;

+ platform: Fix when no serial node in dtb (@Xiaoguang Xing in [1d0d0a6b1519d99](https://github.com/sophgo/opensbi/commit/1d0d0a6b1519d99) at 2024-12-25 01:40:40)
    > SOPHGO BM1690 SoC TP dtb has not serial node.
    > Signed-off-by: bowen.pang &lt;bowen.pang@sophgo.com&gt;

+ lib: add mtimer and mswi support for bm1690 ap and tp (@Xiaoguang Xing in [ba3b2e626902e1a](https://github.com/sophgo/opensbi/commit/ba3b2e626902e1a) at 2024-12-25 01:38:33)
    > mswi and mtimer&#x27; address of bm1690 ap and tp is not contiguous,
    > so make them separately.
    > Signed-off-by: Xiaoguang Xing &lt;xiaoguang.xing@sophgo.com&gt;

+ platform: generic: add sophgo sg2044 and bm1690 soc support (@Xiaoguang Xing in [4e26aa8747e11dd](https://github.com/sophgo/opensbi/commit/4e26aa8747e11dd) at 2024-12-25 01:38:12)
    > Signed-off-by: Xiaoguang Xing &lt;xiaoguang.xing@sophgo.com&gt;

## [linux-riscv(sg2044-dev-6.12)](https://github.com/sophgo/linux-riscv/tree/sg2044-dev-6.12)

+ sophgo/veth: Get ip address from /proc/sgdrv/vethip (@xiangwen.jiang in [d93d203ad2081eb](https://github.com/sophgo/linux-riscv/commit/d93d203ad2081eb) at 2025-01-08 09:48:56)
    > Signed-off-by: xiangwen.jiang &lt;xiangwen.jiang@sophgo.com&gt;

+ irqchip/thead-c900-aclint-sswi: Add ACPI support (@Jingyu Li in [d3302993751b299](https://github.com/sophgo/linux-riscv/commit/d3302993751b299) at 2025-01-08 07:32:46)
    > Add ACPI support in ACLINT-SSWI early probe. Treat ACLINT-SSWI as a fake IMSIC
    > that can only handle IPIs in a software manner. Use the IMSIC-related fields in
    > the MADT table to obtain the register base address of ACLINT-SSWI.
    > Note that when booting with ACPI, ACLINT-SSWI cannot coexist with the standard
    > IMSIC driver, as the IMSIC driver parses the ACPI table entries before ACLINT-SSWI,
    > resulting in error logs. Therefore, we disable the IMSIC-related kernel drivers.
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ irqchip/sg2044-msi: Handle non-512 numbers of MSI vectors cases. (@Jingyu Li in [01fe4f2e5c9b603](https://github.com/sophgo/linux-riscv/commit/01fe4f2e5c9b603) at 2025-01-06 13:41:52)
    > Add the property &quot;sophgo,msi-num-vecs&quot; to specify the number of MSI vectors to
    > avoid error log occur when getting irqs in turn, such as:
    > [    3.464650] sg2044-msi 7ee00000.msi-controller: error -ENXIO: IRQ msi504 not found
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ dts: Change rp memory layout for BM1690 (@bokai.zeng in [15dd7947a580593](https://github.com/sophgo/linux-riscv/commit/15dd7947a580593) at 2025-01-06 13:07:08)
    > Signed-off-by: bokai.zeng &lt;bokai.zeng@sophgo.com&gt;

+ dts: Keep pcie msi 8 interrupts (@bokai.zeng in [e2fc96e27965df3](https://github.com/sophgo/linux-riscv/commit/e2fc96e27965df3) at 2025-01-06 13:05:42)
    > Signed-off-by: bokai.zeng &lt;bokai.zeng@sophgo.com&gt;

+ pci: Compatible with acpi and dtb (@kun-chang in [c7fef95f75ea8d4](https://github.com/sophgo/linux-riscv/commit/c7fef95f75ea8d4) at 2025-01-06 03:25:42)
    > - When ACPI CONFIG is ture, the kernel supports ACPI and DTB.
    > - When ACPI CONFIG is false, the kernel compiles through and
    > the kernel only supports DTB.
    > Signed-off-by: kun-chang &lt;kun.chang@sophgo.com&gt;

+ acpi: Add MSI controller&#x27;s HID to acpi_honor_dep_ids (@kun-chang in [a6fb7809d388f43](https://github.com/sophgo/linux-riscv/commit/a6fb7809d388f43) at 2025-01-04 05:04:54)
    > - We found that the previous dependency description for PCI was incomplete,
    > as there is a description of INTX functionality in PCI in ACPI, resulting
    > in the &quot;honor_deps&quot; being seen as true. In fact, now the &#x27;_DEP&#x27; described
    > in the ACPI table does not exist in &quot;acpi_honor_dep_ids&quot; when checked in
    > the kernel, and this dependency is invalid. When we remove the description
    > of INTX functionality in ACPI, the previous PCI device will still be probed
    > before the MSI controller and unable to function properly.
    > - We should ensure that all dependencies added to the device are valid, and all
    > dependencies are probed before the device.
    > - Like:&quot;Interrupt controller &lt;-- Link Device + MSI Controller &lt;-- PCI Host bridge&quot;.
    > Signed-off-by: kun-chang &lt;kun.chang@sophgo.com&gt;

+ pci: Fix pci_alloc_irq_vectors panic (@Jingyu Li in [e2f8fc362ce88ee](https://github.com/sophgo/linux-riscv/commit/e2f8fc362ce88ee) at 2025-01-04 05:04:42)
    > Commit bc7acc0 (of: property: fw_devlink: Do not use interrupt-parent
    > directly) dropped the explicit fw_devlink handling of &quot;interrupt-parent&quot;.
    > SG2044 PCIe device depends on the MSI controller, so we modify the
    > &quot;interrupt-parent&quot; to &quot;msi-parent&quot; to ensure the probe order and device
    > link. The following error log has been fixed.
    > [    1.752691] ------------[ cut here ]------------
    > [    1.752696] kernel BUG at kernel/irq/msi.c:685!
    > [    1.752702] Kernel BUG [sophgo#1]
    > [    1.752704] Modules linked in:
    > [    1.752711] CPU: 0 UID: 0 PID: 1 Comm: swapper/0 Not tainted 6.12.7 sophgo#16
    > [    1.752716] Hardware name: SOPHGO SOPHGO SG2044 EVB/SOPHGO SG2044 EVB, BIOS V1.0 Not Set
    > [    1.752718] epc : msi_domain_activate+0x74/0x7e
    > [    1.752732]  ra : msi_domain_activate+0x38/0x7e
    > [    1.752736] epc : ffffffff800b26bc ra : ffffffff800b2680 sp : ffff8f8000313430
    > [    1.752739]  gp : ffffffff81c6f740 tp : ffffaf80806a0000 t0 : 0000000000000000
    > [    1.752741]  t1 : 0000000000000000 t2 : 0000000000000000 s0 : ffff8f8000313470
    > [    1.752743]  s1 : ffffaf80843baa30 a0 : ffffffffffffffda a1 : 0000000000000000
    > [    1.752745]  a2 : 0000000000000000 a3 : 0000000000000000 a4 : ffffaf80843baa00
    > [    1.752746]  a5 : 0000000000000000 a6 : 0000000000000000 a7 : 0000000000000000
    > [    1.752748]  s2 : 000000000000000e s3 : 0000000000000000 s4 : ffffaf8085bb3b00
    > [    1.752750]  s5 : ffff8f8000313608 s6 : 0000000000000000 s7 : ffffaf8086f630c8
    > [    1.752752]  s8 : fffffffffbffffff s9 : ffffffff81b964b0 s10: 0000000000000000
    > [    1.752754]  s11: 0000000000000000 t3 : 0000000000000000 t4 : 0000000000000000
    > [    1.752755]  t5 : 0000000000000000 t6 : 0000000000000000
    > [    1.752757] status: 0000000200000120 badaddr: 0000000000000000 cause: 0000000000000003
    > [    1.752760] [&lt;ffffffff800b26bc&gt;] msi_domain_activate+0x74/0x7e
    > [    1.752766] [&lt;ffffffff800adf96&gt;] __irq_domain_activate_irq+0x46/0x96
    > [    1.752770] [&lt;ffffffff800afd14&gt;] irq_domain_activate_irq+0x38/0x58
    > [    1.752774] [&lt;ffffffff800b2966&gt;] __msi_domain_alloc_irqs+0x212/0x39a
    > [    1.752778] [&lt;ffffffff800b324e&gt;] __msi_domain_alloc_locked+0x12c/0x16a
    > [    1.752782] [&lt;ffffffff800b3ba8&gt;] msi_domain_alloc_irqs_all_locked+0x54/0xaa
    > [    1.752787] [&lt;ffffffff8070cb38&gt;] pci_msi_setup_msi_irqs+0x2c/0x46
    > [    1.752795] [&lt;ffffffff8070b860&gt;] __pci_enable_msi_range+0x23c/0x418
    > [    1.752798] [&lt;ffffffff8070a778&gt;] pci_alloc_irq_vectors_affinity+0xec/0x100
    > [    1.752802] [&lt;ffffffff8070a7a6&gt;] pci_alloc_irq_vectors+0x1a/0x2a
    > [    1.752804] [&lt;ffffffff8070d5da&gt;] pcie_portdrv_probe+0x1a2/0x5c0
    > [    1.752809] [&lt;ffffffff807006bc&gt;] local_pci_probe+0x40/0x88
    > [    1.752813] [&lt;ffffffff8070142e&gt;] pci_device_probe+0xb4/0x232
    > [    1.752816] [&lt;ffffffff80879620&gt;] really_probe+0x9e/0x356
    > [    1.752822] [&lt;ffffffff80879954&gt;] __driver_probe_device+0x7c/0x13c
    > [    1.752825] [&lt;ffffffff80879af0&gt;] driver_probe_device+0x38/0xd0
    > [    1.752829] [&lt;ffffffff80879c12&gt;] __device_attach_driver+0x8a/0xec
    > [    1.752832] [&lt;ffffffff808772f6&gt;] bus_for_each_drv+0x70/0xd0
    > [    1.752835] [&lt;ffffffff80879fc0&gt;] __device_attach+0x94/0x196
    > [    1.752838] [&lt;ffffffff8087a0dc&gt;] device_attach+0x1a/0x24
    > [    1.752842] [&lt;ffffffff806f2188&gt;] pci_bus_add_device+0x72/0xf8
    > [    1.752849] [&lt;ffffffff806f224a&gt;] pci_bus_add_devices+0x3c/0x7e
    > [    1.752852] [&lt;ffffffff806f6020&gt;] pci_host_probe+0x96/0xdc
    > [    1.752857] [&lt;ffffffff80d68e0a&gt;] sophgo_dw_pcie_probe+0x1042/0x10a0
    > [    1.752863] [&lt;ffffffff8087c8a0&gt;] platform_probe+0x5e/0xc6
    > [    1.752868] [&lt;ffffffff80879620&gt;] really_probe+0x9e/0x356
    > [    1.752871] [&lt;ffffffff80879954&gt;] __driver_probe_device+0x7c/0x13c
    > [    1.752874] [&lt;ffffffff80879af0&gt;] driver_probe_device+0x38/0xd0
    > [    1.752877] [&lt;ffffffff80879d62&gt;] __driver_attach+0xee/0x1e8
    > [    1.752880] [&lt;ffffffff8087722e&gt;] bus_for_each_dev+0x6c/0xc4
    > [    1.752883] [&lt;ffffffff80878f7a&gt;] driver_attach+0x26/0x34
    > [    1.752886] [&lt;ffffffff808785b0&gt;] bus_add_driver+0x110/0x23e
    > [    1.752889] [&lt;ffffffff8087ae46&gt;] driver_register+0x52/0x106
    > [    1.752893] [&lt;ffffffff8087c436&gt;] __platform_driver_register+0x28/0x34
    > [    1.752897] [&lt;ffffffff80e3d2fc&gt;] sophgo_dw_pcie_driver_init+0x22/0x2c
    > [    1.752910] [&lt;ffffffff8000298a&gt;] do_one_initcall+0x5c/0x1e4
    > [    1.752913] [&lt;ffffffff80e0194c&gt;] kernel_init_freeable+0x296/0x316
    > [    1.752917] [&lt;ffffffff80d712d0&gt;] kernel_init+0x2a/0x17e
    > [    1.752922] [&lt;ffffffff80d7c0ca&gt;] ret_from_fork+0xe/0x1c
    > [    1.752933] Code: eb99 70e2 7442 74a2 4501 6121 4581 4701 4781 8082 (9002) e097
    > [    1.752938] ---[ end trace 0000000000000000 ]---
    > [    1.752941] Kernel panic - not syncing: Fatal exception in interrupt
    > [    1.752943] SMP: stopping secondary CPUs
    > [    2.127393] ---[ end Kernel panic - not syncing: Fatal exception in interrupt ]---
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ of: Fix fdt CRC check failed when ACPI is enabled (@Jingyu Li in [3e9fce22cbaf566](https://github.com/sophgo/linux-riscv/commit/3e9fce22cbaf566) at 2025-01-04 05:03:04)
    > The EFI Stub will generate an empty DTB and append the /chosen node to it when
    > booting ARM64 and RISC-V platfroms with ACPI enabled. That means the DTB is not
    > empty.
    > The commit 7b937cc ignores the above ACPI boot situation, which forces the fdt
    > to be NULL when ACPI is enabled, resulting in the following issue.
    > [    3.491475] OF: fdt: not creating &#x27;/sys/firmware/fdt&#x27;: CRC check failed
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ acpi: Enable BGRT handling on RISC-V (@Jingyu Li in [ea97dc6fbd7c105](https://github.com/sophgo/linux-riscv/commit/ea97dc6fbd7c105) at 2025-01-04 04:26:13)
    > Add ACPI BGRT support on RISC-V, allowing the display of the boot image from the
    > ACPI table during startup.
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ scripts: Workaround find libssl failed (@Xiaoguang Xing in [0971a3a77c6c53d](https://github.com/sophgo/linux-riscv/commit/0971a3a77c6c53d) at 2025-01-04 04:26:13)
    > Signed-off-by: Xiaoguang Xing &lt;xiaoguang.xing@sophgo.com&gt;

+ tools: Add pmbus tool for sophgo power management (@Xiaoguang Xing in [d5ea5c2b23fb547](https://github.com/sophgo/linux-riscv/commit/d5ea5c2b23fb547) at 2025-01-04 04:26:12)
    > Signed-off-by: xingzhe.ma &lt;xingzhe.ma@sophgo.com&gt;

+ tools: Add efuse code used in user-mode (@zhencheng.zhang in [ba1ed16f8040cb2](https://github.com/sophgo/linux-riscv/commit/ba1ed16f8040cb2) at 2025-01-04 04:26:12)
    > - support efuse writing, each bit can only be written onece
    > - support efuse reading
    > - note: addr is the Hard Macro address not Ecc read address
    > Signed-off-by: zhencheng.zhang &lt;zhencheng.zhang@sophgo.com&gt;

+ Revert &quot;sched: Remove sched_setscheduler*() EXPORTs&quot; (@Xiaoguang Xing in [52c7876e2e22c38](https://github.com/sophgo/linux-riscv/commit/52c7876e2e22c38) at 2025-01-04 04:26:12)
    > This reverts commit 616d91b68cd56bcb1954b6a5af7d542401fde772.
    > The sophgo multimedia module requires the thread priority setting
    > function.

+ scripts: Make kernel headers deb package fatter (@Xiaoguang Xing in [335172edcfa35df](https://github.com/sophgo/linux-riscv/commit/335172edcfa35df) at 2025-01-04 04:26:12)
    > Signed-off-by: Xiaoguang Xing &lt;xiaoguang.xing@sophgo.com&gt;

+ tools: Add AP/RP/TP ddr/axi sram R/W performance test for SOPHGO BM1690 (@kai.ma in [0228f7a50d13544](https://github.com/sophgo/linux-riscv/commit/0228f7a50d13544) at 2025-01-04 04:26:12)
    > Signed-off-by: kai.ma &lt;kai.ma@sophgo.com&gt;

+ drivers: Implement some algorithms on snps,designware (@Xiaoguang Xing in [ea71b7918fc496a](https://github.com/sophgo/linux-riscv/commit/ea71b7918fc496a) at 2025-01-04 04:26:11)
    > Basically complete these algorithms include rsa,
    > ecdh(192, 256, 384), ecdsa(192, 256, 384).
    > But ecdsa 521 curve has not been implemented yet.
    > Note that the driver can successfully probe and register,
    > but can not pass testmgr tests provided by linux kernel.
    > Signed-off-by: ruoxi.zhang &lt;ruoxi.zhang@sophgo.com&gt;

+ riscv: Add defconfig for SOPHGO SG2044 and BM1690 (@Xiaoguang Xing in [21b7968330254ba](https://github.com/sophgo/linux-riscv/commit/21b7968330254ba) at 2025-01-04 04:26:11)
    > Signed-off-by: Xiaoguang Xing &lt;xiaoguang.xing@sophgo.com&gt;

+ drivers: Add mfd/mmc/spi/serial ACPI for SOPHGO SG2044 and BM1690 (@Xiaoguang Xing in [0941b1ace5050d8](https://github.com/sophgo/linux-riscv/commit/0941b1ace5050d8) at 2025-01-04 04:26:11)
    > Signed-off-by: kun-chang &lt;kun.chang@sophgo.com&gt;

+ riscv: Add dts for SOPHGO SG2044 and BM1690 (@Xiaoguang Xing in [0658dd8ce95c883](https://github.com/sophgo/linux-riscv/commit/0658dd8ce95c883) at 2025-01-04 04:26:11)
    > Signed-off-by: Xiaoguang Xing &lt;xiaoguang.xing@sophgo.com&gt;
    > Signed-off-by: dong.yang &lt;dong.yang@sophgo.com&gt;
    > Signed-off-by: Chao Wei &lt;chao.wei@sophgo.com&gt;
    > Signed-off-by: fengchun.li &lt;fengchun.li@sophgo.com&gt;
    > Signed-off-by: xiangwen.jiang &lt;xiangwen.jiang@sophgo.com&gt;
    > Signed-off-by: chengjun.li &lt;chengjun.li@sophgo.com&gt;
    > Signed-off-by: kun-chang &lt;kun.chang@sophgo.com&gt;
    > Signed-off-by: zhencheng.zhang &lt;zhencheng.zhang@sophgo.com&gt;
    > Signed-off-by: tingzhu.wang &lt;tingzhu.wang@sophgo.com&gt;
    > Signed-off-by: kai.ma &lt;kai.ma@sophgo.com&gt;
    > Signed-off-by: pbw &lt;bowen.pang01@sophgo.com&gt;
    > Signed-off-by: yujing.shen &lt;yujing.shen@sophgo.com&gt;
    > Signed-off-by: wenwen.zhu &lt;wenwen.zhu@sophgo.com&gt;

+ drivers: Add pcie support for SOPHGO SG2044 and BM1690 (@Xiaoguang Xing in [d4d642bf2f1bb29](https://github.com/sophgo/linux-riscv/commit/d4d642bf2f1bb29) at 2025-01-04 04:26:10)
    > Signed-off-by: fengchun.li &lt;fengchun.li@sophgo.com&gt;
    > Signed-off-by: kun-chang &lt;kun.chang@sophgo.com&gt;

+ drivers: Add pwm support for SOPHGO SG2044 and BM1690 (@Xiaoguang Xing in [d210ad7368e91e2](https://github.com/sophgo/linux-riscv/commit/d210ad7368e91e2) at 2025-01-04 04:26:10)
    > Signed-off-by: ruoxi.zhang &lt;ruoxi.zhang@sophgo.com&gt;
    > Signed-off-by: kun-chang &lt;kun.chang@sophgo.com&gt;

+ drivers: Add TPU/RXU/veth support for SOPHGO BM1690 (@Xiaoguang Xing in [544c2d508af9c68](https://github.com/sophgo/linux-riscv/commit/544c2d508af9c68) at 2025-01-04 04:26:10)
    > Signed-off-by: tingzhu.wang &lt;tingzhu.wang@sophgo.com
    > Signed-off-by: bokai.zeng &lt;bokai.zeng@sophgo.com&gt;
    > Signed-off-by: kai.ma &lt;kai.ma@sophgo.com&gt;
    > Signed-off-by: xiangwen.jiang &lt;xiangwen.jiang@sophgo.com&gt;

+ drivers: Add virtual tty support for SOPHGO BM1690 (@Xiaoguang Xing in [3ffe1e3f128c95b](https://github.com/sophgo/linux-riscv/commit/3ffe1e3f128c95b) at 2025-01-04 04:26:10)
    > Signed-off-by: pbw &lt;bowen.pang01@sophgo.com&gt;

+ drivers: Add MSI controller support for SOPHGO SG2044 and BM1690 (@Xiaoguang Xing in [0eca3209361e6f5](https://github.com/sophgo/linux-riscv/commit/0eca3209361e6f5) at 2025-01-04 04:26:10)
    > Signed-off-by: kun-chang &lt;kun.chang@sophgo.com&gt;

+ drivers: Add p2p ethernet support for SOPHGO SG2044 and BM1690 (@Xiaoguang Xing in [17a03ae505cec31](https://github.com/sophgo/linux-riscv/commit/17a03ae505cec31) at 2025-01-04 04:26:09)
    > Signed-off-by: chengjun.li &lt;chengjun.li@sophgo.com&gt;

+ driver: Add ethernet for SOPHGO SG2044 and BM1690 (@Xiaoguang Xing in [e80af0ddea27750](https://github.com/sophgo/linux-riscv/commit/e80af0ddea27750) at 2025-01-04 04:26:00)
    > Signed-off-by: dong.yang &lt;dong.yang@sophgo.com&gt;
    > Signed-off-by: chengjun.li &lt;chengjun.li@sophgo.com&gt;

+ Revert &quot;net: stmmac: make stmmac_{probe|remove}_config_dt static&quot; (@Xiaoguang Xing in [7ed1e4030b91ab6](https://github.com/sophgo/linux-riscv/commit/7ed1e4030b91ab6) at 2025-01-04 03:58:06)
    > This reverts commit b2504f649bda92094dedfb721c7d49f9a348d500.

+ drivers: Add efuse support for SOPHGO SG2044 and BM1690 (@Xiaoguang Xing in [e4ec848acc8dbcc](https://github.com/sophgo/linux-riscv/commit/e4ec848acc8dbcc) at 2025-01-04 03:56:56)
    > Signed-off-by: zhencheng.zhang &lt;zhencheng.zhang@sophgo.com&gt;

+ drivers: Add spi-nor flash support for SOPHGO SG2044 and BM1690 (@Xiaoguang Xing in [7ce48ce9ad6e50a](https://github.com/sophgo/linux-riscv/commit/7ce48ce9ad6e50a) at 2025-01-04 03:56:43)
    > Signed-off-by: zhencheng.zhang &lt;zhencheng.zhang@sophgo.com&gt;

+ drivers: Add reset support for SOPHGO SG2044 and BM1690 (@Xiaoguang Xing in [f370fe0a3c9efe4](https://github.com/sophgo/linux-riscv/commit/f370fe0a3c9efe4) at 2025-01-04 03:55:51)
    > Signed-off-by: dong.yang &lt;dong.yang@sophgo.com&gt;

+ drivers: Add pinctrl support for SOPHGO SG2044 and BM1690 (@Xiaoguang Xing in [1cf34cc0c7c7bfe](https://github.com/sophgo/linux-riscv/commit/1cf34cc0c7c7bfe) at 2025-01-04 03:55:41)
    > Signed-off-by: dong.yang &lt;dong.yang@sophgo.com&gt;

+ drivers: Add clock support for SOPHGO SG2044 and BM1690 (@Xiaoguang Xing in [cf259b07a97cc13](https://github.com/sophgo/linux-riscv/commit/cf259b07a97cc13) at 2025-01-04 03:55:25)
    > Signed-off-by: dong.yang &lt;dong.yang@sophgo.com&gt;

+ riscv: Workaround cpu hang when swith mmu page table (@Xiaoguang Xing in [aaf4831ef686f2d](https://github.com/sophgo/linux-riscv/commit/aaf4831ef686f2d) at 2025-01-04 03:54:28)
    > Signed-off-by: Xiaoguang Xing &lt;xiaoguang.xing@sophgo.com&gt;

+ irqchip: add T-HEAD C900 ACLINT SSWI driver (@Inochi Amaoto in [8f39214546e4e95](https://github.com/sophgo/linux-riscv/commit/8f39214546e4e95) at 2025-01-02 23:02:46)
    > Add a driver for the T-HEAD C900 ACLINT SSWI device. This device allows
    > the system with T-HEAD cpus to send ipi via fast device interface.
    > Signed-off-by: Inochi Amaoto &lt;inochiama@gmail.com&gt;

+ dt-bindings: interrupt-controller: Add Sophgo SG2044 ACLINT SSWI (@Inochi Amaoto in [79fad6add9018d8](https://github.com/sophgo/linux-riscv/commit/79fad6add9018d8) at 2025-01-02 23:02:46)
    > Sophgo SG2044 has a new version of T-HEAD C920, which implement
    > a fully featured T-HEAD ACLINT device. This ACLINT device contains
    > a SSWI device to support fast S-mode IPI.
    > Add necessary compatible string for the T-HEAD ACLINT sswi device.
    > Link: https://www.xrvm.com/product/xuantie/C920
    > Signed-off-by: Inochi Amaoto &lt;inochiama@gmail.com&gt;
    > Reviewed-by: Conor Dooley &lt;conor.dooley@microchip.com&gt;

+ riscv: defconfig: Enable T-HEAD C900 ACLINT SSWI drivers (@Inochi Amaoto in [35ce38d5507b2fa](https://github.com/sophgo/linux-riscv/commit/35ce38d5507b2fa) at 2025-01-02 23:02:46)
    > Add support for T-HEAD C900 ACLINT SSWI irqchip.
    > Signed-off-by: Inochi Amaoto &lt;inochiama@gmail.com&gt;

## [sophgo-edk2(devel-sg2044)](https://github.com/sophgo/sophgo-edk2/tree/devel-sg2044)

+ Update edk2-platforms (@Jingyu Li in [a598737259fcd41](https://github.com/sophgo/sophgo-edk2/commit/a598737259fcd41) at 2025-01-08 10:17:18)
    > - SG2044Pkg/AcpiTables: Add ACLINT-SSWI support
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ Update edk2-platforms (@Jingyu Li in [5f7971aa4e1dffb](https://github.com/sophgo/sophgo-edk2/commit/5f7971aa4e1dffb) at 2025-01-07 14:41:49)
    > - SG2044Pkg/AcpiTables: Reserve interrupts 856-863 for TPU
    > - Resolve Password Compilation Errors and Optimize UI Design
    > - SG2044Pkg/UiApp: Add Enable/Disable Password Feature Control to the Menu
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ Update edk2-platforms (@Jingyu Li in [f658b704c2097ae](https://github.com/sophgo/sophgo-edk2/commit/f658b704c2097ae) at 2025-01-03 15:34:21)
    > - SG2044Pkg/AcpiTables: update &quot;_CCA&quot; value
    > - Add Password Functionality to BIOS
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ Update edk2-platforms (@Jingyu Li in [93851849a5a093c](https://github.com/sophgo/sophgo-edk2/commit/93851849a5a093c) at 2025-01-02 14:25:29)
    > - SG2044Pkg/AcpiTables/Rhct.alsc: add ISA extensions
    > - SG2044Pkg/AcpiTables/Rhct.alsc: update ISA node length
    > - SG2044Pkg/AcpiTables: update Rhct.alsc
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ README: Add iASL install steps (@Jingyu Li in [8577135ff3b66cf](https://github.com/sophgo/sophgo-edk2/commit/8577135ff3b66cf) at 2025-01-02 02:01:53)
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ Update edk2-platforms (@Jingyu Li in [12de069bf777eb9](https://github.com/sophgo/sophgo-edk2/commit/12de069bf777eb9) at 2024-12-31 13:48:09)
    > - Merge branch &#x27;tianocore:master&#x27; into devel-sg2044
    > - SG2044Pkg/AcpiTables: update pci routing table and add &quot;LINK_DEVICE&quot;
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ Update edk2-platforms (@Jingyu Li in [915f82224428681](https://github.com/sophgo/sophgo-edk2/commit/915f82224428681) at 2024-12-27 01:14:46)
    > - Update the SMBIOS table population code based on the latest conf.ini
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ Update edk2-platforms (@Jingyu Li in [d11d11a7618f47a](https://github.com/sophgo/sophgo-edk2/commit/d11d11a7618f47a) at 2024-12-25 13:24:19)
    > - IniParserLib: Add MAC address parsing handler
    > - Sophgo/MotorcommPhyDxe: Add Motorcomm YT8531 PHY driver
    > - Sophgo/DwMac4SnpDxe: Add dwmac4 SNP driver
    > - FirmwareManagerUiDxe: Add &quot;Update CONF.INI&quot; button
    > - Optimize the current design for displaying BIOS MENU Information
    > - SG2044Pkg/AcpiTables: update SPCR table to support earlycon
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ Update edk2-platforms (@Jingyu Li in [64283071131ea90](https://github.com/sophgo/sophgo-edk2/commit/64283071131ea90) at 2024-12-24 12:23:49)
    > - SG2044Pkg/AcpiTables: update PPTT table to support cpu and cache info
    > - SG2044Pkg/AcpiTables: delete device &quot;MCU&quot; and &quot;RESP&quot;
    > - SG2044/Dsdt: Add dependency between PCIe host and MSI controller
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ Update edk2-platforms (@Jingyu Li in [1e121ed34c507da](https://github.com/sophgo/sophgo-edk2/commit/1e121ed34c507da) at 2024-12-23 13:22:37)
    > - SG2044Pkg: Add DwGpioDxe
    > - SG2044Pkg/AcpiPlatformDxe: Fix not found bug when call entry point
    > - SG2044Pkg/AcpiTables: add thermal support
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ Update edk2-platforms (@Jingyu Li in [20f4f77e088dcfd](https://github.com/sophgo/sophgo-edk2/commit/20f4f77e088dcfd) at 2024-12-20 09:57:08)
    > - Modify SMBIOS Parsing from conf.ini to address an issue
    > - Resolve the issue where the system hangs during boot due to missing conf.ini
    > in SMBIOS
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ Update edk2-platforms (@Jingyu Li in [b77710097bdd76e](https://github.com/sophgo/sophgo-edk2/commit/b77710097bdd76e) at 2024-12-19 01:43:13)
    > - SG2044Pkg/AcpiTables: device &quot;MSI&quot; supports 512 interrupt descriptions
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ Update edk2-platforms (@Jingyu Li in [301967445c1060b](https://github.com/sophgo/sophgo-edk2/commit/301967445c1060b) at 2024-12-17 12:42:12)
    > - Resolve Current Issues in BIOS MENU
    > - SG2044Pkg: Add FirmwareManagerUiDxe
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ Update edk2-platforms (@Jingyu Li in [b48c43ef9f514bb](https://github.com/sophgo/sophgo-edk2/commit/b48c43ef9f514bb) at 2024-12-13 13:46:26)
    > - SG2044Pkg/AcpiTables: Correct the &quot;_CCA&quot; value of Dsdt/Pci.asl
    > - Enhance Current BIOS MENU Features
    > - SG2044Pkg: Add DwSpiDxe driver
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ Update edk2-non-osi (@Jingyu Li in [2439cb59030c467](https://github.com/sophgo/sophgo-edk2/commit/2439cb59030c467) at 2024-12-13 10:20:04)
    > - ASpeed/ASpeedGopBinPkg: Update AST2500 RISC-V GOP driver
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ Update edk2-platforms and edk2-non-osi (@Jingyu Li in [2a7503584bd6a2e](https://github.com/sophgo/sophgo-edk2/commit/2a7503584bd6a2e) at 2024-12-12 09:26:04)
    > - SG2044Pkg: Add AST2500 UEFI GOP driver
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ Update edk2 and edk2-platforms (@Jingyu Li in [083c4f9e789c26f](https://github.com/sophgo/sophgo-edk2/commit/083c4f9e789c26f) at 2024-12-11 13:35:29)
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ Update edk2-platforms (@Jingyu Li in [5ce6a6332ace174](https://github.com/sophgo/sophgo-edk2/commit/5ce6a6332ace174) at 2024-12-09 14:05:13)
    > - Improve Hotkey Logic and Adjust BIOS MENU Page Design
    > - Sophgo/PciPlatformLib: Fix PCIe switch enumerate bug
    > - Sophgo/FirmwareUpdate: Add firmware update application
    > - SG2044Pkg/AcpiTables: Update Dsdt/Intc.asl to support MSI controller
    > - SG2044Pkg/AcpiTables: Add Pci.asl and update Mcfg.aslc
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ Update edk2-platforms (@Jingyu Li in [6cee0c69f76ac92](https://github.com/sophgo/sophgo-edk2/commit/6cee0c69f76ac92) at 2024-12-04 01:51:57)
    > - Ds1307RealTimeClockLib: Add Pcd variable
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ Update edk2-platforms (@Jingyu Li in [24e456c688186e2](https://github.com/sophgo/sophgo-edk2/commit/24e456c688186e2) at 2024-12-03 01:36:47)
    > - Sophgo/SG2044Pkg: Add Hash2 Protocols to resolve TcpDxe loading issue
    > - Sophgo: RTC runtime support virtual address
    > - Sophgo/StmmacMdioDxe: Add MDIO driver
    > - Sophgo: Fixbug flash runtime support virtual address
    > - StmmacMdioDxe: Fix bug for the undeclared macros
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ Update edk2-platforms (@Jingyu Li in [6cf298895ff4891](https://github.com/sophgo/sophgo-edk2/commit/6cf298895ff4891) at 2024-11-28 15:14:22)
    > - Enhance the BIOS menu functionality
    > - SpifmcDxe: Replace macro with PcdFlashPartitionTableAddress
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ Update edk2-platforms (@Jingyu Li in [36fe75b373a4bd0](https://github.com/sophgo/sophgo-edk2/commit/36fe75b373a4bd0) at 2024-11-27 13:35:28)
    > - SpifmcDxe: Refactor I/O resource population phase
    > - NorFlashDxe: Add GetFlashVariableOffset() function
    > - FlashFvbDxe: Refactor FVB R/W policies
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ Update edk2-platforms (@Jingyu Li in [b13f8220be00bab](https://github.com/sophgo/sophgo-edk2/commit/b13f8220be00bab) at 2024-11-25 14:03:11)
    > - Sophgo/SpiDxe: Add SPIFMC DMMR mode
    > - Silicon/Sophgo: Rename SpiDxe to SpifmcDxe
    > - TrngLib: Fix load access page fault bug
    > - Sophgo/SG2044Pkg: Add DwI2cDxe
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;



