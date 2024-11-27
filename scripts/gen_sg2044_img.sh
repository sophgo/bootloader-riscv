#!/bin/bash

RV_UBUNTU_OFFICIAL_IMAGE=ubuntu-24.04.1-riscv64-sg2044-20241025.template.img
DOWNLOAD_RV_UBUNTU_OFFICIAL_IMAGE="wget https://github.com/sophgo/bootloader-riscv/releases/download/sg2044-v0.1/ubuntu-24.04.1-riscv64-sg2044-20241025.template.img.xz"
UNCOMPRESS_RV_UBUNTU_OFFICIAL_IMAGE="unxz $RV_UBUNTU_OFFICIAL_IMAGE.xz"

RV_EULER_OFFICIAL_IMAGE=openEuler-24.03-riscv64-sg2044-20241025.template.img
DOWNLOAD_RV_EULER_OFFICIAL_IMAGE="wget https://github.com/sophgo/bootloader-riscv/releases/download/sg2044-v0.1/openEuler-24.03-riscv64-sg2044-20241025.template.img.xz"
UNCOMPRESS_RV_EULER_OFFICIAL_IMAGE="unxz $RV_EULER_OFFICIAL_IMAGE.xz"

function get_distro_info()
{
    DISTRO_NAME=`echo $1 | awk -F '-' '{print $1}'`
    DISTRO_VERSION=`echo $1 | awk -F '-' '{print $2}'`
    DISTRO_ARCH=`echo $1 | awk -F '-' '{print $3}'`
    DISTRO_CHIP=`echo $1 | awk -F '-' '{print $4}'`
    DISTRO_DATE=`echo $1 | awk -F '-' '{print $5}' | awk -F '.' '{print $1}'`
}

function gen_distro_img_name()
{
    get_distro_info $1

    local DISTRO_DATE=`date +%Y%m%d`

    BUILD_DISTRO_IMAGE=$DISTRO_NAME-$DISTRO_VERSION-$DISTRO_ARCH-$CHIP-$DISTRO_DATE.img
}

function install_deb_packages()
{
    echo 'copy bsp packages'
    sudo cp -v -r $RV_DEB_INSTALL_DIR $RV_OUTPUT_DIR/root/home/sophgo

    echo install linux image...
    # following lines must not be started with space or tab.
    sudo chroot $RV_OUTPUT_DIR/root /bin/bash << "EOT"
dpkg -i /home/sophgo/bsp-debs/linux-image-*[0-9].deb
apt autoremove -y
apt-mark hold `find /home/sophgo/bsp-debs -name 'linux-image*' | xargs basename -s .deb`
EOT
}

function install_rpm_packages()
{
    echo 'copy bsp packages'
    sudo cp -v -r $RV_RPM_INSTALL_DIR $RV_OUTPUT_DIR/root/home/sophgo

    echo install linux image...
    # following lines must not be started with space or tab.
    sudo chroot $RV_OUTPUT_DIR/root /bin/bash << "EOT"
rpm -i /home/sophgo/bsp-rpms/kernel-*.rpm
dracut --force --regenerate-all --no-hostonly
grub2-mkconfig -o /boot/grub2/grub.cfg
EOT

}

# $1: deb, install deb packages; rpm, install rpm packages
# IN RV_OFFICIAL_IMAGE: offcial image name, just file name, not including dirname
# IN RV_SOPHGO_IMAGE: sophgo image name,  just file name, not including dirname
# IN RV_DISTRO: offcial distro name, not image name, not full dirname
function build_rv_image()
{
	echo $0

	echo 'remove old image'
	rm -f $RV_OUTPUT_DIR/$RV_SOPHGO_IMAGE

	echo 'copying image'
	cp -v $RV_DISTRO_DIR/$RV_DISTRO/$RV_OFFICIAL_IMAGE $RV_OUTPUT_DIR/$RV_SOPHGO_IMAGE

	# 1st partition is EFI, 2nd partition is ROOT
	echo 'creating loop devices'
	local loops=$(sudo kpartx -av $RV_OUTPUT_DIR/$RV_SOPHGO_IMAGE | cut -d ' ' -f 3)
	local efi_part=$(echo $loops | cut -d ' ' -f 1)
	local root_part=$(echo $loops | cut -d ' ' -f 2)

	echo 'mounting partitions'
	mkdir -p $RV_OUTPUT_DIR/root
	sudo mount /dev/mapper/$root_part $RV_OUTPUT_DIR/root
	# as far as I know, all distributions mount EFI partition to /boot/efi
	sudo mount /dev/mapper/$efi_part $RV_OUTPUT_DIR/root/boot/efi

	echo 'copying bootloaders'
	local EFI_PARTITION_DIR=$RV_OUTPUT_DIR/root/boot/efi

	sudo mkdir $EFI_PARTITION_DIR/riscv64

	sudo cp -v $RV_FIRMWARE_INSTALL_DIR/fsbl.bin $EFI_PARTITION_DIR/riscv64

	if [ -f $RV_FIRMWARE_INSTALL_DIR/${CHIP^^}.fd ]; then
		sudo cp -v $RV_FIRMWARE_INSTALL_DIR/${CHIP^^}.fd $EFI_PARTITION_DIR/riscv64
	fi

	if [ -f $RV_FIRMWARE_INSTALL_DIR/u-boot.bin ]; then
		sudo cp -v $RV_FIRMWARE_INSTALL_DIR/u-boot.bin $EFI_PARTITION_DIR/riscv64
	fi

	sudo cp -v $RV_FIRMWARE_INSTALL_DIR/initrd.img $EFI_PARTITION_DIR/riscv64
	sudo cp -v $RV_FIRMWARE_INSTALL_DIR/zsbl.bin $EFI_PARTITION_DIR/riscv64
	sudo cp -v $RV_FIRMWARE_INSTALL_DIR/fw_dynamic.bin $EFI_PARTITION_DIR/riscv64

	if [ "$CHIP" = "bm1690" ]; then
		sudo cp -v $RV_FIRMWARE_INSTALL_DIR/rp_Image $EFI_PARTITION_DIR/riscv64
		sudo cp -v $RV_TOP_DIR/bootloader-riscv/scripts/bm1690-config.ini $RV_FIRMWARE_INSTALL_DIR/conf.ini
		sudo cp -v $RV_FIRMWARE_INSTALL_DIR/conf.ini $EFI_PARTITION_DIR/riscv64
	else
		sudo cp -v $RV_FIRMWARE_INSTALL_DIR/riscv64_Image $EFI_PARTITION_DIR/riscv64
	fi

	sudo cp -v $RV_FIRMWARE_INSTALL_DIR/*.dtb $EFI_PARTITION_DIR/riscv64

	echo 'mount system files'
	sudo mount --bind /proc $RV_OUTPUT_DIR/root/proc
	sudo mount --bind /sys $RV_OUTPUT_DIR/root/sys
	sudo mount --bind /dev $RV_OUTPUT_DIR/root/dev
	sudo mount --bind /dev/pts $RV_OUTPUT_DIR/root/dev/pts

	echo 'create vendor home directory'
	sudo mkdir -p $RV_DEB_INSTALL_DIR $RV_OUTPUT_DIR/root/home/sophgo

		if [ $1 == "rpm" ]; then
		install_rpm_packages
	else
		install_deb_packages
	fi

	echo cleanup
	sudo sync
	sudo umount -R $RV_OUTPUT_DIR/root

	sleep 0.2

	sudo kpartx -d $RV_OUTPUT_DIR/$RV_SOPHGO_IMAGE

	echo 'cleanup done, compressing'

	sudo rm -r $RV_OUTPUT_DIR/root

	gen_distro_img_name $RV_OFFICIAL_IMAGE
	mv $RV_OUTPUT_DIR/$RV_SOPHGO_IMAGE $RV_OUTPUT_DIR/$BUILD_DISTRO_IMAGE
	# overwrite the existing one
	xz -v --keep --force -T $(nproc) $RV_OUTPUT_DIR/$BUILD_DISTRO_IMAGE

	echo "build $RV_DISTRO successfully!"
}

function build_rv_ubuntu_image()
{
    RV_OFFICIAL_IMAGE=$RV_UBUNTU_OFFICIAL_IMAGE
    RV_SOPHGO_IMAGE=$RV_UBUNTU_SOPHGO_IMAGE
    RV_DISTRO=$RV_UBUNTU_DISTRO
    build_rv_image deb
}

function clean_rv_ubuntu_image()
{
    gen_distro_img_name $RV_UBUNTU_OFFICIAL_IMAGE
    rm -rf $RV_OUTPUT_DIR/$DISTRO_NAME-$DISTRO_VERSION-$DISTRO_ARCH-$CHIP-*
}

function build_rv_euler_image()
{
    RV_OFFICIAL_IMAGE=$RV_EULER_OFFICIAL_IMAGE
    RV_SOPHGO_IMAGE=$RV_EULER_SOPHGO_IMAGE
    RV_DISTRO=$RV_EULER_DISTRO
    build_rv_image rpm
}

function clean_rv_euler_image()
{
    gen_distro_img_name $RV_EULER_OFFICIAL_IMAGE
    rm -rf $RV_OUTPUT_DIR/$DISTRO_NAME-$DISTRO_VERSION-$DISTRO_ARCH-$CHIP-*
}
