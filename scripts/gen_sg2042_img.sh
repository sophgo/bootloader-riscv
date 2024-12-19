#!/bin/bash

RV_UBUNTU_OFFICIAL_IMAGE=ubuntu-24.04.1-preinstalled-server-riscv64+unmatched.img
DOWNLOAD_RV_UBUNTU_OFFICIAL_IMAGE="wget https://cdimage.ubuntu.com/releases/noble/release/$RV_UBUNTU_OFFICIAL_IMAGE.xz"
UNCOMPRESS_RV_UBUNTU_OFFICIAL_IMAGE="unxz $RV_UBUNTU_OFFICIAL_IMAGE.xz"

RV_FEDORA_OFFICIAL_IMAGE=fedora-disk-server_sophgo_sg2042-f38-20230523-014306.n.0-sda.raw
DOWNLOAD_RV_FEDORA_OFFICIAL_IMAGE="wget http://openkoji.iscas.ac.cn/kojifiles/work/tasks/8061/1418061/$RV_FEDORA_OFFICIAL_IMAGE.xz"
UNCOMPRESS_RV_FEDORA_OFFICIAL_IMAGE="unxz $RV_FEDORA_OFFICIAL_IMAGE.xz"

RV_EULER_OFFICIAL_IMAGE=openEuler-24.03-V1-base-sg2042-testing.img
DOWNLOAD_RV_EULER_OFFICIAL_IMAGE="wget https://repo.tarsier-infra.isrc.ac.cn/openEuler-RISC-V/testing/20240708/v0.1/SG2042/$RV_EULER_OFFICIAL_IMAGE.zst"
UNCOMPRESS_RV_EULER_OFFICIAL_IMAGE="unzstd $RV_EULER_OFFICIAL_IMAGE.zst"

RV_SERVICE_DIR=$RV_TOP_DIR/bootloader-riscv/service

function build_rv_ubuntu_image()
{
	echo build_rv_ubuntu_image
	echo create an image file...
	rm -f $RV_OUTPUT_DIR/$RV_UBUNTU_SOPHGO_IMAGE
	dd if=/dev/zero of=$RV_OUTPUT_DIR/$RV_UBUNTU_SOPHGO_IMAGE bs=1GiB count=10

	echo create partitions...
	sudo parted $RV_OUTPUT_DIR/$RV_UBUNTU_SOPHGO_IMAGE mktable msdos
	sudo parted $RV_OUTPUT_DIR/$RV_UBUNTU_SOPHGO_IMAGE mkpart p fat32 0% 256MiB
	sudo parted $RV_OUTPUT_DIR/$RV_UBUNTU_SOPHGO_IMAGE mkpart p ext4 256MiB 100%
	loops=$(sudo kpartx -av $RV_OUTPUT_DIR/$RV_UBUNTU_SOPHGO_IMAGE | cut -d ' ' -f 3)
	efi_part=$(echo $loops | cut -d ' ' -f 1)
	root_part=$(echo $loops | cut -d ' ' -f 2)
	sleep 3
	sudo mkfs.vfat /dev/mapper/$efi_part -n EFI
	sudo mkfs.ext4 /dev/mapper/$root_part

	echo copy bootloader...
	mkdir -p $RV_OUTPUT_DIR/efi
	sudo mount /dev/mapper/$efi_part $RV_OUTPUT_DIR/efi
	sudo mkdir -p $RV_OUTPUT_DIR/efi/riscv64
	sudo mkdir -p $RV_OUTPUT_DIR/efi/EFI/BOOT
	sudo mkdir -p $RV_OUTPUT_DIR/efi/EFI/ubuntu

	if [ "$CHIP" = "mango" ]; then
		sudo cp $RV_FIRMWARE/fip.bin $RV_OUTPUT_DIR/efi/
		sudo cp $RV_FIRMWARE_INSTALL_DIR/SG2042.fd $RV_OUTPUT_DIR/efi/riscv64
		# sudo cp $RV_FIRMWARE_INSTALL_DIR/u-boot.bin $RV_OUTPUT_DIR/efi/riscv64
	elif [ "$CHIP" = "bm1690" ]; then
		sudo cp $RV_FIRMWARE_INSTALL_DIR/fsbl.bin $RV_OUTPUT_DIR/efi/riscv64
	elif [ "$CHIP" = "sg2044" ]; then
		sudo cp $RV_FIRMWARE_INSTALL_DIR/fsbl.bin $RV_OUTPUT_DIR/efi/riscv64
	else
		sudo cp $RV_FIRMWARE_INSTALL_DIR/${CHIP^^}.fd $RV_OUTPUT_DIR/efi/riscv64
	fi

	sudo cp $RV_FIRMWARE_INSTALL_DIR/initrd.img $RV_OUTPUT_DIR/efi/riscv64/

	if [ "$CHIP" = "mango" ]; then
		sudo cp $RV_FIRMWARE_INSTALL_DIR/zsbl.bin $RV_OUTPUT_DIR/efi/
	else
		sudo cp $RV_FIRMWARE_INSTALL_DIR/zsbl.bin $RV_OUTPUT_DIR/efi/riscv64
	fi

	sudo cp $RV_FIRMWARE_INSTALL_DIR/fw_dynamic.bin $RV_OUTPUT_DIR/efi/riscv64
	if [ "$CHIP" = "bm1690" ]; then
		sudo cp $RV_FIRMWARE_INSTALL_DIR/rp_Image $RV_OUTPUT_DIR/efi/riscv64/riscv64_Image
	else
		sudo cp $RV_FIRMWARE_INSTALL_DIR/riscv64_Image $RV_OUTPUT_DIR/efi/riscv64
	fi
	sudo cp $RV_FIRMWARE_INSTALL_DIR/*.dtb $RV_OUTPUT_DIR/efi/riscv64

	echo copy ubuntu...
	loops=$(sudo kpartx -av $RV_DISTRO_DIR/$RV_UBUNTU_DISTRO/$RV_UBUNTU_OFFICIAL_IMAGE | cut -d ' ' -f 3)
	ubuntu_root_part=$(echo $loops | cut -d ' ' -f 1)
	sudo dd if=/dev/mapper/$ubuntu_root_part of=/dev/mapper/$root_part bs=256M
	sudo e2fsck -f -y /dev/mapper/$root_part
	sudo resize2fs /dev/mapper/$root_part

	echo mount root partition...
	mkdir -p $RV_OUTPUT_DIR/root
	sudo mount /dev/mapper/$root_part $RV_OUTPUT_DIR/root

	if [[ "$CHIP_NUM" = "multi" ]];then
		echo cp power good scripts
		sudo cp $RV_SERVICE_DIR/sg2042-pisces/powergood/powergood.service $RV_OUTPUT_DIR/root/etc/systemd/system/
		sudo cp $RV_SERVICE_DIR/sg2042-pisces/powergood/power_good.sh $RV_OUTPUT_DIR/root/usr/local/
	fi

	sudo mount --bind /proc $RV_OUTPUT_DIR/root/proc
	sudo mount --bind /sys $RV_OUTPUT_DIR/root/sys
	sudo mount --bind /dev $RV_OUTPUT_DIR/root/dev
	sudo mount --bind /dev/pts $RV_OUTPUT_DIR/root/dev/pts

# following lines must not be started with space or tab.
sudo chroot $RV_OUTPUT_DIR/root /bin/bash << "EOT"
useradd -m -s /bin/bash ubuntu
echo "ubuntu:ubuntu" | chpasswd
usermod -a -G sudo ubuntu

sed -i -e '
/\%sudo/ c \
%sudo	ALL=(ALL) NOPASSWD: ALL
' /etc/sudoers

exit
EOT

	echo copy bsp package...
	sudo cp -r $RV_DEB_INSTALL_DIR $RV_OUTPUT_DIR/root/home/ubuntu/

	if [ "$CHIP" = "mango" ]; then
		echo copy tools package...
		sudo cp -r $RV_TOOLS_DIR $RV_OUTPUT_DIR/root/home/ubuntu
	fi

	echo install linux image...
	pushd $RV_OUTPUT_DIR/root
# following lines must not be started with space or tab.
sudo chroot . /bin/bash << "EOT"
sed -i '/UEFI/d' /etc/fstab
apt purge -y linux-image-6.8.0*
apt purge -y linux-headers-6.8.0*
dpkg -i /home/ubuntu/bsp-debs/linux-image-*[0-9].deb
apt autoremove -y
rm -rf /etc/initramfs/post-update.d/flash-kernel
rm -rf /etc/kernel/postinst.d/zz-flash-kernel
apt-mark hold linux-image-6.1.31
cat > /etc/modprobe.d/sg2042-blacklist.conf << EOF
blacklist switchtec
EOF

# replace UUID to LABEL
mv /etc/fstab /etc/fstab_bak
cat > /etc/fstab << EOF
LABEL=cloudimg-rootfs	/		ext4	defaults,discard,errors=remount-ro 0 1
LABEL=EFI		/boot/efi	vfat    defaults,discard,errors=remount-ro 0 1
EOF

#enable powergood service in host to adapt BMC wdt function
echo enable powergood service
if [ -e /etc/systemd/system/powergood.service ]; then systemctl enable powergood.service; fi

exit
EOT
	popd

	echo cleanup...
	sync
	sudo umount -R $RV_OUTPUT_DIR/root
	sudo umount $RV_OUTPUT_DIR/efi
	sudo kpartx -d $RV_OUTPUT_DIR/$RV_UBUNTU_SOPHGO_IMAGE
	sudo kpartx -d $RV_DISTRO_DIR/$RV_UBUNTU_DISTRO/$RV_UBUNTU_OFFICIAL_IMAGE
	sudo rm -r $RV_OUTPUT_DIR/efi
	sudo rm -r $RV_OUTPUT_DIR/root

	echo "build ubuntu image successfully!"
}

function clean_rv_ubuntu_image()
{
	rm -f $RV_OUTPUT_DIR/$RV_UBUNTU_SOPHGO_IMAGE
}

function build_rv_euler_image()
{
	echo build_rv_euler_image
	echo create an image file...
	mkdir -p $RV_OUTPUT_DIR
	rm -f $RV_OUTPUT_DIR/$RV_EULER_SOPHGO_IMAGE
	sudo dd if=/dev/zero of=$RV_OUTPUT_DIR/$RV_EULER_SOPHGO_IMAGE bs=1GiB count=20

	echo create partitions...
	sudo parted $RV_OUTPUT_DIR/$RV_EULER_SOPHGO_IMAGE mktable msdos
	sudo parted $RV_OUTPUT_DIR/$RV_EULER_SOPHGO_IMAGE mkpart p fat32 0% 256MiB
	sudo parted $RV_OUTPUT_DIR/$RV_EULER_SOPHGO_IMAGE mkpart p ext4 256MiB 100%
	loops=$(sudo kpartx -av $RV_OUTPUT_DIR/$RV_EULER_SOPHGO_IMAGE | cut -d ' ' -f 3)
	efi_part=$(echo $loops | cut -d ' ' -f 1)
	root_part=$(echo $loops | cut -d ' ' -f 2)
	sleep 3
	sudo mkfs.vfat /dev/mapper/$efi_part -n EFI
	sudo mkfs.ext4 /dev/mapper/$root_part

	echo copy bootloader...
	mkdir $RV_OUTPUT_DIR/efi
	sudo mount /dev/mapper/$efi_part $RV_OUTPUT_DIR/efi
	sudo mkdir -p $RV_OUTPUT_DIR/efi/riscv64

	if [[ "$CHIP" = "sg2044" || "$CHIP" = "bm1690" ]]; then
		sudo cp $RV_FIRMWARE/fsbl.bin $RV_OUTPUT_DIR/efi/riscv64
		sudo cp $RV_FIRMWARE_INSTALL_DIR/zsbl.bin $RV_OUTPUT_DIR/efi/riscv64
	else
		sudo cp $RV_FIRMWARE/fip.bin $RV_OUTPUT_DIR/efi/
		sudo cp $RV_FIRMWARE_INSTALL_DIR/zsbl.bin $RV_OUTPUT_DIR/efi/
	fi
	# sudo cp $RV_FIRMWARE_INSTALL_DIR/grub.cfg $RV_OUTPUT_DIR/efi/
	# sudo cp $RV_FIRMWARE_INSTALL_DIR/grubriscv64.efi $RV_OUTPUT_DIR/efi/
	sudo cp $RV_FIRMWARE_INSTALL_DIR/fw_dynamic.bin $RV_OUTPUT_DIR/efi/riscv64
	sudo cp $RV_FIRMWARE_INSTALL_DIR/riscv64_Image $RV_OUTPUT_DIR/efi/riscv64
	# sudo cp $RV_FIRMWARE_INSTALL_DIR/u-boot.bin $RV_OUTPUT_DIR/efi/riscv64
	sudo cp $RV_FIRMWARE_INSTALL_DIR/*.dtb $RV_OUTPUT_DIR/efi/riscv64
	sudo cp $RV_FIRMWARE_INSTALL_DIR/initrd.img $RV_OUTPUT_DIR/efi/riscv64
	sudo touch $RV_OUTPUT_DIR/efi/BOOT

	echo copy euler...
	loops=$(sudo kpartx -av $RV_DISTRO_DIR/$RV_EULER_DISTRO/$RV_EULER_OFFICIAL_IMAGE | cut -d ' ' -f 3)
	euler_root_part=$(echo $loops | cut -d ' ' -f 3)
	echo ============ rootfs $euler_root_part
	sudo dd if=/dev/mapper/$euler_root_part of=/dev/mapper/$root_part bs=256M status=progress
	sudo e2fsck -f -y /dev/mapper/$root_part
	sudo resize2fs /dev/mapper/$root_part
	sudo e2label /dev/mapper/$root_part ROOT

	echo mount root partition...
	mkdir -p $RV_OUTPUT_DIR/root
	sudo mount /dev/mapper/$root_part $RV_OUTPUT_DIR/root

	if [[ "$CHIP_NUM" = "multi" ]];then
		echo cp power good scripts
		sudo cp $RV_SERVICE_DIR/sg2042-pisces/powergood/powergood.service $RV_OUTPUT_DIR/root/etc/systemd/system/
		sudo cp $RV_SERVICE_DIR/sg2042-pisces/powergood/power_good.sh $RV_OUTPUT_DIR/root/usr/local/
	fi

	sudo mount --bind /proc $RV_OUTPUT_DIR/root/proc
	sudo mount --bind /sys $RV_OUTPUT_DIR/root/sys
	sudo mount --bind /dev $RV_OUTPUT_DIR/root/dev
	sudo mount --bind /dev/pts $RV_OUTPUT_DIR/root/dev/pts
	sudo mount --bind /run/ 	$RV_OUTPUT_DIR/root/run
	sudo mv $RV_OUTPUT_DIR/root/etc/hosts $RV_OUTPUT_DIR/root/etc/hosts-bak
	sudo cp /etc/hosts $RV_OUTPUT_DIR/root/etc/
	#echo add user euler:Sophgo12#
# following lines must not be started with space or tab.

# following lines must not be started with space or tab.
	echo copy bsp package...
	sudo cp -r $RV_RPM_INSTALL_DIR $RV_OUTPUT_DIR/root/home/

	echo install linux image...
# following lines must not be started with space or tab.
sudo chroot $RV_OUTPUT_DIR/root /bin/env ROOT_PART="$root_part" /bin/bash << "EOT"
echo add user euler
useradd -m -s /bin/bash euler
echo "euler:sophgo@123" | chpasswd
sed -i -e '/NOPASSWD/a\%euler   ALL=(ALL) NOPASSWD: ALL' /etc/sudoers
echo install kernel
rpm -ivh --force /home/bsp-rpms/kernel-[0-9]*.riscv64.rpm
# The following command is to solve the problem of not updating the extlinux.conf file when installing kernel RPM package.
kernel_version=`ls /home/bsp-rpms/kernel-[0-9]*.riscv64.rpm | cut -d '-' -f 3 | cut -d '.' -f 1-3`
echo update initramfs
dracut --kver $kernel_version --force
echo build exlinux
mkdir -p /boot/extlinux
cat > /boot/extlinux/extlinux.conf << EOF
## /boot/extlinux/extlinux.conf

default euler_sophgo
menu title linuxboot menu
prompt 0
timeout 50

label euler_sophgo
	menu label euler Sophgo in SD
	linux /boot/vmlinuz-$kernel_version
	initrd /boot/initramfs-$kernel_version.img
	append  console=ttyS0,115200 root=LABEL=ROOT rootfstype=ext4 rootwait rw earlycon selinux=0 LANG=en_US.UTF-8 nvme.use_threaded_interrupts=1
EOF

cat > /etc/modprobe.d/sg2042-blacklist.conf << EOF
blacklist switchtec
EOF
# replace UUID to LABEL
mv /etc/fstab /etc/fstab_bak
cat > /etc/fstab << EOF
LABEL=ROOT	/		ext4	defaults,noatime,x-systemd.device-timeout=300s,x-systemd.mount-timeout=300s 0 0
LABEL=EFI	/boot/efi	vfat    defaults,noatime,x-systemd.device-timeout=300s,x-systemd.mount-timeout=300s 0 0
EOF

#enable powergood service in host to adapt BMC wdt function
echo enable powergood service
if [ -e /etc/systemd/system/powergood.service ]; then systemctl enable powergood.service; fi

exit

EOT

	echo cleanup...
	sync
	sleep 60
	sudo rm $RV_OUTPUT_DIR/root/etc/hosts
	sudo mv $RV_OUTPUT_DIR/root/etc/hosts-bak $RV_OUTPUT_DIR/root/etc/hosts
	sudo umount -R $RV_OUTPUT_DIR/root
	sudo umount /dev/mapper/$efi_part
	sudo umount /dev/mapper/$root_part
	sudo kpartx -d $RV_OUTPUT_DIR/$RV_EULER_SOPHGO_IMAGE
	sudo kpartx -d $RV_DISTRO_DIR/$RV_EULER_DISTRO/$RV_EULER_OFFICIAL_IMAGE
	sudo rm -r $RV_OUTPUT_DIR/efi
	sudo rm -r $RV_OUTPUT_DIR/root

	echo "build euler image successfully!"
}

function clean_rv_euler_image()
{
	rm -rf $RV_OUTPUT_DIR/$RV_EULER_SOPHGO_IMAGE
}

function build_rv_fedora_image()
{
	echo build_rv_fedora_image
	echo create an image file...
	rm -f $RV_OUTPUT_DIR/$RV_FEDORA_SOPHGO_IMAGE
	dd if=/dev/zero of=$RV_OUTPUT_DIR/$RV_FEDORA_SOPHGO_IMAGE bs=1GiB count=20

	echo create partitions...
	sudo parted $RV_OUTPUT_DIR/$RV_FEDORA_SOPHGO_IMAGE mktable msdos
	sudo parted $RV_OUTPUT_DIR/$RV_FEDORA_SOPHGO_IMAGE mkpart p fat32 0% 256MiB
	sudo parted $RV_OUTPUT_DIR/$RV_FEDORA_SOPHGO_IMAGE mkpart p ext4 256MiB 1280MiB
	sudo parted $RV_OUTPUT_DIR/$RV_FEDORA_SOPHGO_IMAGE mkpart p ext4 1280MiB 100%

	loops=$(sudo kpartx -av $RV_OUTPUT_DIR/$RV_FEDORA_SOPHGO_IMAGE | cut -d ' ' -f 3)
	efi_part=$(echo $loops | cut -d ' ' -f 1)
	boot_part=$(echo $loops | cut -d ' ' -f 2)
	root_part=$(echo $loops | cut -d ' ' -f 3)
	sleep 3
	sudo mkfs.vfat /dev/mapper/$efi_part -n EFI
	sudo mkfs.ext4 /dev/mapper/$boot_part
	sudo mkfs.ext4 /dev/mapper/$root_part

	echo copy bootloader...
	mkdir -p $RV_OUTPUT_DIR/efi
	sudo mount /dev/mapper/$efi_part $RV_OUTPUT_DIR/efi
	sudo mkdir -p $RV_OUTPUT_DIR/efi/riscv64
	sudo mkdir -p $RV_OUTPUT_DIR/efi/EFI/BOOT
	sudo mkdir -p $RV_OUTPUT_DIR/efi/EFI/fedora

	if [[ "$CHIP" = "sg2044" || "$CHIP" = "bm1690" ]];then
	sudo cp $RV_FIRMWARE/fsbl.bin $RV_OUTPUT_DIR/efi/riscv64
	sudo cp $RV_FIRMWARE_INSTALL_DIR/zsbl.bin $RV_OUTPUT_DIR/efi/riscv64
	else
	sudo cp $RV_FIRMWARE/fip.bin $RV_OUTPUT_DIR/efi
	sudo cp $RV_FIRMWARE_INSTALL_DIR/zsbl.bin $RV_OUTPUT_DIR/efi
	fi
	sudo cp $RV_FIRMWARE_INSTALL_DIR/fw_dynamic.bin $RV_OUTPUT_DIR/efi/riscv64
	sudo cp $RV_FIRMWARE_INSTALL_DIR/riscv64_Image $RV_OUTPUT_DIR/efi/riscv64
	sudo cp $RV_FIRMWARE_INSTALL_DIR/SG2042.fd $RV_OUTPUT_DIR/efi/riscv64
	# sudo cp $RV_FIRMWARE_INSTALL_DIR/u-boot.bin $RV_OUTPUT_DIR/efi/riscv64
	sudo cp $RV_FIRMWARE_INSTALL_DIR/*.dtb $RV_OUTPUT_DIR/efi/riscv64
	sudo cp $RV_FIRMWARE_INSTALL_DIR/initrd.img $RV_OUTPUT_DIR/efi/riscv64

	echo build GRUB2...
	build_rv_fedora_grub
	sudo cp $RV_FIRMWARE_INSTALL_DIR/grubriscv64/fedora-rootfs/grubriscv64.efi $RV_OUTPUT_DIR/efi/EFI/BOOT/BOOTRISCV64.EFI
	sudo cp $RV_FIRMWARE_INSTALL_DIR/grubriscv64/fedora-rootfs/grubriscv64.efi $RV_OUTPUT_DIR/efi/EFI/fedora/
	sudo cp $RV_FIRMWARE_INSTALL_DIR/grubriscv64/fedora.cfg $RV_OUTPUT_DIR/efi/EFI/fedora/grub.cfg

	echo copy fedora ...
	loops=$(sudo kpartx -av $RV_DISTRO_DIR/$RV_FEDORA_DISTRO/$RV_FEDORA_OFFICIAL_IMAGE | cut -d ' ' -f 3)
	fedora_boot_part=$(echo $loops | cut -d ' ' -f 2)
	fedora_root_part=$(echo $loops | cut -d ' ' -f 3)
	sudo dd if=/dev/mapper/$fedora_boot_part of=/dev/mapper/$boot_part bs=256M
	sudo e2fsck -f -y /dev/mapper/$boot_part
	sudo resize2fs /dev/mapper/$boot_part
	sudo e2label /dev/mapper/$boot_part BOOT
	sudo dd if=/dev/mapper/$fedora_root_part of=/dev/mapper/$root_part bs=256M
	sudo e2fsck -f -y /dev/mapper/$root_part
	sudo resize2fs /dev/mapper/$root_part
	sudo e2label /dev/mapper/$root_part ROOT

	mkdir -p $RV_OUTPUT_DIR/root
	sudo mount /dev/mapper/$root_part $RV_OUTPUT_DIR/root

	if [[ "$CHIP_NUM" = "multi" ]];then
		echo cp power good scripts
		sudo cp $RV_SERVICE_DIR/sg2042-pisces/powergood/powergood.service $RV_OUTPUT_DIR/root/etc/systemd/system/
		sudo cp $RV_SERVICE_DIR/sg2042-pisces/powergood/power_good.sh $RV_OUTPUT_DIR/root/usr/local/
	fi

	sudo mount --bind /proc $RV_OUTPUT_DIR/root/proc
	sudo mount --bind /sys $RV_OUTPUT_DIR/root/sys
	sudo mount --bind /dev $RV_OUTPUT_DIR/root/dev
	sudo mount --bind /dev/pts $RV_OUTPUT_DIR/root/dev/pts

	echo add user fedora:fedora
# following lines must not be started with space or tab.
sudo chroot $RV_OUTPUT_DIR/root /bin/bash << "EOT"
useradd -m -s /bin/bash fedora
echo "fedora:fedora" | chpasswd
sed -i -e '/NOPASSWD/a\%fedora   ALL=(ALL) NOPASSWD: ALL' /etc/sudoers
exit
EOT

	echo copy bsp package...
	sudo cp -r $RV_RPM_INSTALL_DIR $RV_OUTPUT_DIR/root/home/fedora/

	echo install linux image...
# following lines must not be started with space or tab.
sudo chroot $RV_OUTPUT_DIR/root /bin/env BOOT_PART="$boot_part" /bin/bash << "EOT"
mount /dev/mapper/$BOOT_PART /boot
rpm -ivh --force /home/fedora/bsp-rpms/kernel-[0-9]*.riscv64.rpm
rpm -e kernel-6.2.16
rm -rf /boot/*6.2.16*
rpm -e kernel-modules kernel-modules-core kernel-core
rpm -ivh --force /home/fedora/bsp-rpms/kernel-headers-[0-9]*.riscv64.rpm
rpm -ivh --force /home/fedora/bsp-rpms/kernel-devel-[0-9]*.riscv64.rpm


# The following command is to solve the problem of not updating the extlinux.conf file when installing kernel RPM package.
kernel_version=`ls /home/fedora/bsp-rpms/kernel-[0-9]*.riscv64.rpm | cut -d '-' -f 3 | cut -d '.' -f 1-3`
mv /boot/extlinux/extlinux.conf /boot/extlinux/extlinux.conf_bak
cat > /boot/extlinux/extlinux.conf << EOF
## /boot/extlinux/extlinux.conf

default fedora_sophgo
menu title linuxboot menu
prompt 0
timeout 50

label fedora_sophgo
	menu label Fedora Sophgo in SD
	linux /vmlinuz-$kernel_version
	initrd /initramfs-$kernel_version.img
	append  console=ttyS0,115200 root=LABEL=ROOT rootfstype=ext4 rootwait rw earlycon selinux=0 LANG=en_US.UTF-8   cma=512M swiotlb=65536
EOF

# update the grub.cfg
rm -rf /boot/grub.cfg

cat > /boot/grub2/grub.cfg << EOF
set default=0
set timeout_style=menu
set timeout=2

set term="vt100"

menuentry 'Fedora 38 on SG2042' {
    linux /vmlinuz-$kernel_version  console=ttyS0,115200 root=LABEL=ROOT rootfstype=ext4 rootwait rw earlycon selinux=0 LANG=en_US.UTF-8  cma=512M swiotlb=65536
    initrd /initramfs-$kernel_version.img
}

EOF
umount /boot

# replace UUID to LABEL
mv /etc/fstab /etc/fstab_bak
cat > /etc/fstab << EOF
LABEL=ROOT	/		ext4	defaults,noatime,x-systemd.device-timeout=300s,x-systemd.mount-timeout=300s 0 0
LABEL=BOOT	/boot		ext4	defaults,noatime,x-systemd.device-timeout=300s,x-systemd.mount-timeout=300s 0 0
LABEL=EFI	/boot/efi	vfat    defaults,noatime,x-systemd.device-timeout=300s,x-systemd.mount-timeout=300s 0 0
EOF

cat > /etc/modprobe.d/sg2042-blacklist.conf << EOF
blacklist switchtec
EOF

#enable powergood service in host to adapt BMC wdt function
echo enable powergood service
if [ -e /etc/systemd/system/powergood.service ]; then systemctl enable powergood.service; fi

exit
EOT

	echo cleanup...
	sync
	sudo umount -R $RV_OUTPUT_DIR/root
	sudo umount /dev/mapper/$efi_part
	sudo umount /dev/mapper/$root_part
	sudo kpartx -d $RV_OUTPUT_DIR/$RV_FEDORA_SOPHGO_IMAGE
	sudo kpartx -d $RV_DISTRO_DIR/$RV_FEDORA_DISTRO/$RV_FEDORA_OFFICIAL_IMAGE
	rm -r $RV_OUTPUT_DIR/efi
	rm -r $RV_OUTPUT_DIR/root

	echo "build fedora image successfully!"
}

function clean_rv_fedora_image()
{
	rm -f $RV_OUTPUT_DIR/$RV_FEDORA_SOPHGO_IMAGE
}
