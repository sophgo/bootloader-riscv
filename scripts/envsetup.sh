#!/bin/bash

#######################################################################
# global variables
#######################################################################
function get_rv_top()
{
	local TOPFILE=bootloader-riscv/scripts/envsetup.sh
	if [ -n "$TOP" -a -f "$TOP/$TOPFILE" ] ; then
		# The following circumlocution ensures we remove symlinks from TOP.
		(cd $TOP; PWD= /bin/pwd)
	else
		if [ -f $TOPFILE ] ; then
			# The following circumlocution (repeated below as well) ensures
			# that we record the true directory name and not one that is
			# faked up with symlink names.
			PWD= /bin/pwd
		else
			local HERE=$PWD
			T=
			while [ \( ! \( -f $TOPFILE \) \) -a \( $PWD != "/" \) ]; do
				\cd ..
				T=`PWD= /bin/pwd -P`
			done
			\cd $HERE

			if [ -f "$T/$TOPFILE" ]; then
				echo $T
			fi
		fi
	fi
}

CHIP=${CHIP}
KERNEL_VARIANT=${KERNEL_VARIANT:-normal} # normal, mininum, debug
CHIP_NUM=${CHIP_NUM:-single} # single, multi
VENDOR=${VENDOR:-sophgo}

# absolute path
RV_TOP_DIR=${TOP_DIR:-$(get_rv_top)}

RV_SCRIPTS_DIR=$RV_TOP_DIR/bootloader-riscv/scripts
RV_OUTPUT_DIR=$RV_TOP_DIR/install/soc_$CHIP/"$CHIP_NUM"_chip

RV_ZSBL_SRC_DIR=$RV_TOP_DIR/zsbl
RV_ZSBL_BUILD_DIR=$RV_ZSBL_SRC_DIR/build/$CHIP/$KERNEL_VARIANT
RV_SBI_SRC_DIR=$RV_TOP_DIR/opensbi

RV_KERNEL_SRC_DIR=$RV_TOP_DIR/linux-riscv
RV_KERNEL_BUILD_DIR=$RV_KERNEL_SRC_DIR/build/$CHIP/$KERNEL_VARIANT

RV_BUILDROOT_DIR=$RV_TOP_DIR/bootloader-riscv/buildroot
RV_UROOT_DIR=$RV_TOP_DIR/bootloader-riscv/u-root

RV_LTP_SRC_DIR=$RV_TOP_DIR/bsp-solutions/ltp
RV_LTP_OUTPUT_DIR=$RV_OUTPUT_DIR/ltp

RV_DISTRO_DIR=$RV_TOP_DIR/distro_riscv
RV_UBUNTU_DISTRO=ubuntu
RV_FEDORA_DISTRO=fedora

RV_UBUNTU_OFFICIAL_IMAGE=ubuntu-22.10-preinstalled-server-riscv64+unmatched.img
DOWNLOAD_RV_UBUNTU_OFFICIAL_IMAGE="wget https://cdimage.ubuntu.com/releases/22.10/release/$RV_UBUNTU_OFFICIAL_IMAGE.xz"
UNCOMPRESS_RV_UBUNTU_OFFICIAL_IMAGE="unxz $RV_UBUNTU_OFFICIAL_IMAGE.xz"

RV_FEDORA_OFFICIAL_IMAGE=fedora-disk-server_sophgo_sg2042-f38-20230523-014306.n.0-sda.raw
DOWNLOAD_RV_FEDORA_OFFICIAL_IMAGE="wget http://openkoji.iscas.ac.cn/kojifiles/work/tasks/8061/1418061/$RV_FEDORA_OFFICIAL_IMAGE.xz"
UNCOMPRESS_RV_FEDORA_OFFICIAL_IMAGE="unxz $RV_FEDORA_OFFICIAL_IMAGE.xz"

RV_UBUNTU_SOPHGO_IMAGE=ubuntu-sophgo.img
RV_FEDORA_SOPHGO_IMAGE=fedora-sophgo.img

RV_DEB_INSTALL_DIR=$RV_OUTPUT_DIR/bsp-debs
RV_RPM_INSTALL_DIR=$RV_OUTPUT_DIR/bsp-rpms
RV_FIRMWARE_INSTALL_DIR=$RV_OUTPUT_DIR/firmware

RV_FIRMWARE=$RV_TOP_DIR/bootloader-riscv/firmware
RV_TOOLS_DIR=$RV_OUTPUT_DIR/tools

RV_GCC_DIR=$RV_TOP_DIR/gcc-riscv
RV_ELF_GCC_INSTALL_DIR=$RV_GCC_DIR/gcc-riscv64-unknown-elf
RV_LINUX_GCC_INSTALL_DIR=$RV_GCC_DIR/gcc-riscv64-unknown-linux-gnu

# riscv specific variables
HOST_ARCH=`uname -m`

if [ $HOST_ARCH == 'riscv64' ]; then
	RISCV64_LINUX_CROSS_COMPILE=
else
	RISCV64_LINUX_CROSS_COMPILE=$RV_LINUX_GCC_INSTALL_DIR/bin/riscv64-unknown-linux-gnu-
fi
RISCV64_ELF_CROSS_COMPILE=$RV_ELF_GCC_INSTALL_DIR/bin/riscv64-unknown-elf-

#######################################################################
# common function
#######################################################################

function show_rv_env()
{
	echo "CHIP: $CHIP"
	echo "KERNEL_VARIANT: $KERNEL_VARIANT"
	echo "VENDOR: $VENDOR"
	echo "RISCV64_LINUX_CROSS_COMPILE: $RISCV64_LINUX_CROSS_COMPILE"
	echo "RISCV64_ELF_CROSS_COMPILE: $RISCV64_ELF_CROSS_COMPILE"
	echo "RV_TOP_DIR: $RV_TOP_DIR"
	echo "RV_OUTPUT_DIR: $RV_OUTPUT_DIR"
	echo "RV_SCRIPTS_DIR: $RV_SCRIPTS_DIR"
	echo "RV_ZSBL_SRC_DIR: $RV_ZSBL_SRC_DIR"
	echo "RV_ZSBL_BUILD_DIR: $RV_ZSBL_BUILD_DIR"
	echo "RV_SBI_SRC_DIR: $RV_SBI_SRC_DIR"
	echo "RV_KERNEL_SRC_DIR: $RV_KERNEL_SRC_DIR"
	echo "RV_KERNEL_BUILD_DIR: $RV_KERNEL_BUILD_DIR"
}

function show_rv_functions()
{
	echo "show_rv_env			-print build environment"
	echo "show_rv_functions     		-print all funtions "
	echo ""
	echo "build_rv_gcc			-build gcc from source"
	echo "build_rv_zsbl			-build zsbl bin"
	echo "build_rv_sbi			-build sbi bin"
	echo "build_rv_kernel			-build linuxboot kernel"
	echo "build_rv_ubuntu_kernel		-build ubuntu kernel"
	echo "build_rv_fedora_kernel		-build fedora kernel"
	echo "build_rv_ramfs			-build buildroot"
	echo "build_rv_uroot			-build u-root for linuxboot"
	echo "build_rv_ltp			-build ltp"
	echo "build_rv_ubuntu_perf_tool     	-build ubuntu perf tool source package"
	echo "build_rv_fedora_perf_tool     	-build fedora perf tool source package"
	echo "build_rv_firmware                 -build firmware(zsbl,sbi,kernel,uroot)"
	echo "build_rv_firmware_bin		-build firmware bin"
	echo "build_rv_firmware_image		-build firmware image"
	echo "build_rv_firmware_package 	-build firmware package"
	echo "build_rv_ubuntu_distro		-dowload ubuntu image from offical"
	echo "build_rv_fedora_distro		-download fedora image from offical"
	echo "build_rv_ubuntu_image		-only build sophgo ubuntu image"
	echo "build_rv_fedora_image		-only build sophgo fedora image"
	echo "build_rv_ubuntu			-build sophgo ubuntu image"
	echo "build_rv_fedora			-build sophgo fedora image"
	echo "build_rv_all			-build all bin and image(default: ubuntu)"
	echo ""
	echo "clean_rv_gcc			-clean gcc obj files"
	echo "clean_rv_zsbl			-clean zsbl obj files"
	echo "clean_rv_sbi			-clean sbi obj files"
	echo "clean_rv_kernel			-clean linuxboot kernel obj files"
	echo "clean_rv_ubuntu_kernel		-clean ubuntu kernel obj files"
	echo "clean_rv_fedora_kernel		-clean fedora kernel obj files"
	echo "clean_rv_ramfs			-clean buildroot obj files"
	echo "clean_rv_uroot			-clean uroot obj files"
	echo "clean_rv_ltp			-clean ltp obj files"
	echo "clean_rv_ubuntu_perf_tool     	-clean ubuntu perf tool files"
	echo "clean_rv_fedora_perf_tool     	-clean fedora perf tool files"
	echo "clean_rv_firmware                 -clean firmware(zsbl,sbi,kernel,uroot)"
	echo "clean_rv_firmware_bin		-clean firmware bin"
	echo "clean_rv_firmware_image		-clean firmware image"
	echo "clean_rv_firmware_package 	-clean firmware package"
	echo "clean_rv_ubuntu_distro		-clean ubuntu image"
	echo "clean_rv_fedora_distro		-clean fedora image"
	echo "clean_rv_ubuntu_image		-clean ubuntu image"
	echo "clean_rv_fedora_image		-clean fedora image"
	echo "clean_rv_ubuntu			-clean ubuntu image"
	echo "clean_rv_fedora			-clean feodra image"
	echo "clean_rv_all			-clean all bin and image(default: ubuntu)"
}

#######################################################################
# build toolchain
#######################################################################

function build_rv_linux_gcc()
{
	mkdir -p $RV_GCC_DIR

	pushd $RV_GCC_DIR
	if [ ! -d riscv-gnu-toolchain ]; then
	    git clone https://github.com/riscv-collab/riscv-gnu-toolchain.git
	fi
	pushd riscv-gnu-toolchain
	rm -rf $RV_LINU_GCC_INSTALL_DIR
	make clean
	git checkout 2022.08.08
	./configure --prefix=$RV_LINUX_GCC_INSTALL_DIR
	make linux
	popd
	popd
}

function build_rv_elf_gcc()
{
	mkdir -p $RV_GCC_DIR

	pushd $RV_GCC_DIR
	if [ ! -d riscv-gnu-toolchain ]; then
	    git clone https://github.com/riscv-collab/riscv-gnu-toolchain.git
	fi
	pushd riscv-gnu-toolchain
	rm -rf $RV_ELF_GCC_INSTALL_DIR
	make clean
	git checkout 2022.08.08
	./configure --with-cmodel=medany --with-arch=rv64imafdc --with-abi=lp64d --prefix=$RV_ELF_GCC_INSTALL_DIR
	make
	popd
	popd
}

function build_rv_gcc()
{
	build_rv_elf_gcc
	build_rv_linux_gcc
}

function clean_rv_gcc()
{
	if [ -d $RV_GCC_DIR/riscv-gnu-toolchain ]; then
	    pushd $RV_GCC_DIR/riscv-gnu-toolchain
	    make clean
	    popd
	fi
}

#######################################################################
# build bin and image
#######################################################################

function build_rv_zsbl()
{
	local err

	pushd $RV_ZSBL_SRC_DIR
	if [ $CHIP == 'mango' ]; then
		make CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE O=$RV_ZSBL_BUILD_DIR ARCH=riscv sg2042_defconfig
	else
		make CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE O=$RV_ZSBL_BUILD_DIR ARCH=riscv ${CHIP}_defconfig
	fi
	err=$?
	popd

	if [ $err -ne 0 ]; then
		echo "making zsbl config failed"
		return $err
	    fi

	pushd $RV_ZSBL_BUILD_DIR
	make -j$(nproc) CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE ARCH=riscv
	err=$?
	popd

	if [ $err -ne 0 ]; then
		echo "making zsbl failed"
		return $err
	    fi

	mkdir -p $RV_FIRMWARE_INSTALL_DIR

	cp $RV_ZSBL_BUILD_DIR/zsbl.bin $RV_FIRMWARE_INSTALL_DIR
}

function clean_rv_zsbl()
{
	rm -rf $RV_FIRMWARE_INSTALL_DIR/zsbl.bin
	rm -rf $RV_ZSBL_BUILD_DIR
}

function build_rv_sbi()
{
	PLATFORM=generic

	pushd $RV_SBI_SRC_DIR
	make -j$(nproc) CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE PLATFORM=$PLATFORM FW_TEXT_START=0x0 FW_JUMP_ADDR=0x02000000 FW_JUMP_FDT_ADDR=0x20000000 FW_PIC=y BUILD_INFO=y DEBUG=1
	popd

	mkdir -p $RV_FIRMWARE_INSTALL_DIR

	cp $RV_SBI_SRC_DIR/build/platform/$PLATFORM/firmware/fw_jump.bin $RV_FIRMWARE_INSTALL_DIR
	cp $RV_SBI_SRC_DIR/build/platform/$PLATFORM/firmware/fw_jump.elf $RV_FIRMWARE_INSTALL_DIR
}

function clean_rv_sbi()
{
	rm -rf $RV_FIRMWARE_INSTALL_DIR/fw_jump.*

	pushd $RV_SBI_SRC_DIR
	make distclean
	popd
}

function build_rv_kernel()
{
	local RV_KERNEL_CONFIG=${VENDOR}_${CHIP}_${KERNEL_VARIANT}_defconfig
	local err

	pushd $RV_KERNEL_SRC_DIR
	make O=$RV_KERNEL_BUILD_DIR ARCH=riscv CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE $RV_KERNEL_CONFIG
	err=$?
	popd

	if [ $err -ne 0 ]; then
		echo "making kernel config failed"
		return $err
	fi

	pushd $RV_KERNEL_BUILD_DIR
	if [ "$CHIP_NUM" == "multi" ];then
		sed -i 's/# CONFIG_SOPHGO_MULTI_CHIP_CLOCK_SYNC is not set/CONFIG_SOPHGO_MULTI_CHIP_CLOCK_SYNC=y/' .config
	fi
	make -j$(nproc) O=$RV_KERNEL_BUILD_DIR ARCH=riscv CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE LOCALVERSION="" Image dtbs modules
	err=$?
	popd

	if [ $err -ne 0 ]; then
		echo "making kernel modules failed"
		return $err
	fi

	mkdir -p $RV_FIRMWARE_INSTALL_DIR
	cp $RV_KERNEL_BUILD_DIR/arch/riscv/boot/Image $RV_FIRMWARE_INSTALL_DIR/riscv64_Image

	if [ $CHIP != 'qemu' ]; then
	    cp $RV_KERNEL_BUILD_DIR/arch/riscv/boot/dts/sophgo/*.dtb $RV_FIRMWARE_INSTALL_DIR
	fi
}

function clean_rv_kernel()
{
	rm -rf $RV_FIRMWARE_INSTALL_DIR/riscv64_Image
	rm -rf $RV_FIRMWARE_INSTALL_DIR/vmlinux
	rm -rf $RV_FIRMWARE_INSTALL_DIR/*.dtb

	rm -rf $RV_KERNEL_BUILD_DIR
}

function build_rv_ubuntu_kernel()
{
	local RV_KERNEL_CONFIG=${VENDOR}_${CHIP}_ubuntu_defconfig
	local err

	pushd $RV_KERNEL_SRC_DIR
	make O=$RV_KERNEL_BUILD_DIR ARCH=riscv CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE $RV_KERNEL_CONFIG
	err=$?
	popd

	if [ $err -ne 0 ]; then
		echo "making kernel config failed"
		return $err
	fi

	pushd $RV_KERNEL_BUILD_DIR
	rm -f ../linux-*
	rm -rf ./debs

	if [ "$CHIP_NUM" == "multi" ];then
		sed -i 's/# CONFIG_SOPHGO_MULTI_CHIP_CLOCK_SYNC is not set/CONFIG_SOPHGO_MULTI_CHIP_CLOCK_SYNC=y/' .config
	fi

	local KERNELRELEASE=$(make ARCH=riscv LOCALVERSION="" kernelrelease)
	make -j$(nproc) ARCH=riscv CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE LOCALVERSION="" bindeb-pkg
	ret=$?
	if [ $ret -ne 0 ]; then
		popd
		echo "making deb package failed"
		return $ret
	fi

	if [ ! -d $RV_DEB_INSTALL_DIR ]; then
		mkdir -p $RV_DEB_INSTALL_DIR
	fi
	rm -f $RV_DEB_INSTALL_DIR/linux-*.deb
	mv ../linux-image-${KERNELRELEASE}_*.deb $RV_DEB_INSTALL_DIR/linux-image-${KERNELRELEASE}.deb
	mv ../linux-headers-${KERNELRELEASE}_*.deb $RV_DEB_INSTALL_DIR/linux-headers-${KERNELRELEASE}.deb
	mv ../linux-libc-dev_${KERNELRELEASE}-*.deb $RV_DEB_INSTALL_DIR/linux-libc-dev_${KERNELRELEASE}.deb
	popd
}

function clean_rv_ubuntu_kernel()
{
	rm -rf $RV_KERNEL_BUILD_DIR
	rm -f $RV_DEB_INSTALL_DIR/linux-*.deb
}

function build_rv_fedora_kernel()
{
	local RV_KERNEL_CONFIG=${VENDOR}_${CHIP}_fedora_defconfig
	local err

	pushd $RV_KERNEL_SRC_DIR
	make ARCH=riscv CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE $RV_KERNEL_CONFIG
	err=$?
	if [ $err -ne 0 ]; then
		echo "making kernel config failed"
		popd
		return $err
	fi

	if [ "$CHIP_NUM" == "multi" ];then
		sed -i 's/# CONFIG_SOPHGO_MULTI_CHIP_CLOCK_SYNC is not set/CONFIG_SOPHGO_MULTI_CHIP_CLOCK_SYNC=y/' .config
	fi

	if [ -e ~/.rpmmacros ]; then
		mv ~/.rpmmacros ~/.rpmmacros.orig
	fi

# following lines must not be started with space or tab.
cat >> ~/.rpmmacros << "EOT"
%_build_name_fmt        %%{ARCH}/%%{NAME}-%%{VERSION}.%%{ARCH}.rpm
EOT

	make -j$(nproc) ARCH=riscv CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE LOCALVERSION="" rpm-pkg
	ret=$?
	rm ~/.rpmmacros
	if [ -e ~/.rpmmacros.orig ]; then
		mv ~/.rpmmacros.orig ~/.rpmmacros
	fi
	if [ $ret -ne 0 ]; then
		echo "making rpm package failed"
		make ARCH=riscv CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE distclean
		rm kernel-[0-9]*.tar.gz
		rm -rf $HOME/rpmbuild
		popd
		return $ret
	fi

	if [ ! -d $RV_RPM_INSTALL_DIR ]; then
		mkdir -p $RV_RPM_INSTALL_DIR
	else
		rm -f $RV_RPM_INSTALL_DIR/kernel-*.rpm
	fi

	cp $HOME/rpmbuild/RPMS/riscv64/*.rpm $RV_RPM_INSTALL_DIR/
	make ARCH=riscv CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE distclean
	rm kernel-[0-9]*.tar.gz
	rm -rf $HOME/rpmbuild
	popd
}

function clean_rv_fedora_kernel()
{
	pushd $RV_KERNEL_SRC_DIR
	make distclean
	popd
	rm -f $RV_RPM_INSTALL_DIR/kernel-*.rpm
}

function build_rv_ramfs()
{
	local err

	pushd $RV_BUILDROOT_DIR
	make mango_riscv64_mini_defconfig
	err=$?
	popd

	if [ $err -ne 0 ]; then
	    echo 'config buildroot failed'
	    return $err
	fi

	pushd $RV_BUILDROOT_DIR
	make
	err=$?
	popd

	if [ $err -ne 0 ]; then
	    echo 'build buildroot failed'
	    return $err
	fi

	cp $RV_BUILDROOT_DIR/output/images/rootfs.cpio $RV_FIRMWARE_INSTALL_DIR/
}

function clean_rv_ramfs()
{
	rm -rf $RV_FIRMWARE_INSTALL_DIR/rootfs.cpio
	rm -rf $RV_BUILDROOT_DIR/output
}

function build_rv_uroot()
{
	pushd $RV_UROOT_DIR
	GOARCH=riscv64 go build
	GOOS=linux GOARCH=riscv64 $RV_UROOT_DIR/u-root -uroot-source $RV_UROOT_DIR -build bb \
	    -uinitcmd="boot" -files ../busybox/busybox:bin/busybox -o $RV_UROOT_DIR/initramfs.cpio \
		-files "$RV_UROOT_DIR/firmware/:lib/firmware/" \
	    core boot
	popd
	cp $RV_UROOT_DIR/initramfs.cpio $RV_FIRMWARE_INSTALL_DIR/initrd.img
}

function clean_rv_uroot()
{
	rm $RV_FIRMWARE_INSTALL_DIR/initrd.img
}

function build_rv_ubuntu_distro()
{
	mkdir -p $RV_DISTRO_DIR/$RV_UBUNTU_DISTRO

	pushd $RV_DISTRO_DIR/$RV_UBUNTU_DISTRO
	if [ ! -f $RV_UBUNTU_OFFICIAL_IMAGE ] ; then
		$DOWNLOAD_RV_UBUNTU_OFFICIAL_IMAGE
		$UNCOMPRESS_RV_UBUNTU_OFFICIAL_IMAGE
	fi
	popd
}

function clean_rv_ubuntu_distro()
{
	rm $RV_DISTRO_DIR/$RV_UBUNTU_DISTRO/$RV_UBUNTU_OFFICIAL_IMAGE
}

function build_rv_fedora_distro()
{
	mkdir -p $RV_DISTRO_DIR/$RV_FEDORA_DISTRO

	pushd $RV_DISTRO_DIR/$RV_FEDORA_DISTRO
	if [ ! -f $RV_FEDORA_OFFICIAL_IMAGE ] ; then
		$DOWNLOAD_RV_FEDORA_OFFICIAL_IMAGE
		$UNCOMPRESS_RV_FEDORA_OFFICIAL_IMAGE
	fi
	popd
}

function clean_rv_fedora_distro()
{
	rm $RV_DISTRO_DIR/$RV_FEDORA_DISTRO/$RV_FEDORA_OFFICIAL_IMAGE
}

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
	mkdir $RV_OUTPUT_DIR/efi
	sudo mount /dev/mapper/$efi_part $RV_OUTPUT_DIR/efi
	sudo mkdir -p $RV_OUTPUT_DIR/efi/riscv64

	sudo cp $RV_FIRMWARE/fip.bin $RV_OUTPUT_DIR/efi/
	sudo cp $RV_FIRMWARE_INSTALL_DIR/zsbl.bin $RV_OUTPUT_DIR/efi/
	sudo cp $RV_FIRMWARE_INSTALL_DIR/fw_jump.bin $RV_OUTPUT_DIR/efi/riscv64
	sudo cp $RV_FIRMWARE_INSTALL_DIR/riscv64_Image $RV_OUTPUT_DIR/efi/riscv64
	sudo cp $RV_FIRMWARE_INSTALL_DIR/*.dtb $RV_OUTPUT_DIR/efi/riscv64
	sudo cp $RV_FIRMWARE_INSTALL_DIR/initrd.img $RV_OUTPUT_DIR/efi/riscv64
	sudo touch $RV_OUTPUT_DIR/efi/BOOT

	echo copy ubuntu...
	loops=$(sudo kpartx -av $RV_DISTRO_DIR/$RV_UBUNTU_DISTRO/$RV_UBUNTU_OFFICIAL_IMAGE | cut -d ' ' -f 3)
	ubuntu_root_part=$(echo $loops | cut -d ' ' -f 1)
	sudo dd if=/dev/mapper/$ubuntu_root_part of=/dev/mapper/$root_part bs=256M
	sudo e2fsck -f -y /dev/mapper/$root_part
	sudo resize2fs /dev/mapper/$root_part

	echo mount root partition...
	mkdir $RV_OUTPUT_DIR/root
	sudo mount /dev/mapper/$root_part $RV_OUTPUT_DIR/root

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

	echo copy tools package...
	sudo cp -r $RV_TOOLS_DIR $RV_OUTPUT_DIR/root/home/ubuntu

	echo install linux image...
	pushd $RV_OUTPUT_DIR/root
# following lines must not be started with space or tab.
sudo chroot . /bin/bash << "EOT"
sed -i '/UEFI/d' /etc/fstab
echo 'U_BOOT_PARAMETERS="nvme.use_threaded_interrupts=1 nvme_core.io_timeout=3000"' >> /etc/default/u-boot
dpkg -i /home/ubuntu/bsp-debs/linux-image-*[0-9].deb
exit
EOT
	popd

	echo cleanup...
	sync
	sudo umount $RV_OUTPUT_DIR/root/proc
	sudo umount $RV_OUTPUT_DIR/root/sys
	sudo umount $RV_OUTPUT_DIR/root/dev/pts
	sudo umount $RV_OUTPUT_DIR/root/dev
	sudo umount /dev/mapper/$efi_part
	sudo umount /dev/mapper/$root_part
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
	mkdir $RV_OUTPUT_DIR/efi
	sudo mount /dev/mapper/$efi_part $RV_OUTPUT_DIR/efi
	sudo mkdir -p $RV_OUTPUT_DIR/efi/riscv64
	sudo cp $RV_FIRMWARE/fip.bin $RV_OUTPUT_DIR/efi
	sudo cp $RV_FIRMWARE_INSTALL_DIR/zsbl.bin $RV_OUTPUT_DIR/efi
	sudo cp $RV_FIRMWARE_INSTALL_DIR/fw_jump.bin $RV_OUTPUT_DIR/efi/riscv64
	sudo cp $RV_FIRMWARE_INSTALL_DIR/riscv64_Image $RV_OUTPUT_DIR/efi/riscv64
	sudo cp $RV_FIRMWARE_INSTALL_DIR/*.dtb $RV_OUTPUT_DIR/efi/riscv64
	sudo cp $RV_FIRMWARE_INSTALL_DIR/initrd.img $RV_OUTPUT_DIR/efi/riscv64

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
	append  console=ttyS0,115200 root=LABEL=ROOT rootfstype=ext4 rootwait rw earlycon selinux=0 LANG=en_US.UTF-8 nvme.use_threaded_interrupts=1 nvme_core.io_timeout=3000
EOF

umount /boot

# replace UUID to LABEL
mv /etc/fstab /etc/fstab_bak
cat > /etc/fstab << EOF
LABEL=ROOT	/		ext4	defaults,noatime,x-systemd.device-timeout=300s,x-systemd.mount-timeout=300s 0 0
LABEL=BOOT	/boot		ext4	defaults,noatime,x-systemd.device-timeout=300s,x-systemd.mount-timeout=300s 0 0
LABEL=EFI	/boot/efi	vfat    defaults,noatime,x-systemd.device-timeout=300s,x-systemd.mount-timeout=300s 0 0
EOF

exit
EOT

	echo cleanup...
	sync
	sudo umount $RV_OUTPUT_DIR/root/proc
	sudo umount $RV_OUTPUT_DIR/root/sys
	sudo umount $RV_OUTPUT_DIR/root/dev/pts
	sudo umount $RV_OUTPUT_DIR/root/dev
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

function build_rv_ubuntu_perf_tool()
{
	echo make perf package and script...
	pushd $RV_KERNEL_SRC_DIR
	make perf-tar-src-pkg
	popd

	if [ ! -d $RV_TOOLS_DIR/perf ]; then
		mkdir -p $RV_TOOLS_DIR/perf
	fi

	sudo mv $RV_KERNEL_SRC_DIR/perf-*.tar $RV_TOOLS_DIR/perf

	pushd $RV_TOOLS_DIR/perf
	tar -xvf perf-*.tar
	echo -e "#! /bin/bash\n" > build-perf.sh
	echo -e "echo install dependencies..." >> build-perf.sh
	echo -e "sudo apt update" >> build-perf.sh
	echo -e "sudo apt install -y make gcc flex bison libdwarf-dev libbfd-dev libcap-dev" >> build-perf.sh
	echo -e "sudo apt install -y libelf-dev libnuma-dev libperl-dev liblzma-dev python2" >> build-perf.sh
	echo -e "sudo apt install -y python2-dev python-dev-is-python3 python-setuptools" >> build-perf.sh
	echo -e "sudo apt install -y libssl-dev libunwind-dev zlib1g-dev libaio-dev" >> build-perf.sh
	echo -e "sudo apt install -y libdw-dev binutils-dev binutils-multiarch-dev elfutils" >> build-perf.sh
	echo -e "sudo apt install -y libiberty-dev libzstd-dev libaudit-dev libslang2-dev" >> build-perf.sh
	echo -e "sudo apt install -y systemtap-sdt-dev libbabeltrace-dev libbabeltrace-ctf-dev\n" >> build-perf.sh
	echo -e "echo make perf tool..." >> build-perf.sh
	echo -e "pushd perf-*/tools/perf" >> build-perf.sh
	echo -e "sudo make clean" >> build-perf.sh
	echo -e "sudo make" >> build-perf.sh
	echo -e "sudo make install prefix=/usr/local" >> build-perf.sh
	echo -e "popd\n" >> build-perf.sh
	popd
}

function clean_rv_ubuntu_perf_tool()
{
	rm -rf $RV_TOOLS_DIR/perf
}

function build_rv_fedora_perf_tool()
{
	echo "build_rv_fedora_perf_tool is not implemented"
}

function clean_rv_fedora_perf_tool()
{
	echo "clean_rv_fedora_perf_tool is not implemented"
}

function build_rv_firmware()
{
	build_rv_zsbl
	build_rv_sbi
	build_rv_kernel
	build_rv_uroot
}

function clean_rv_firmware()
{
	clean_rv_zsbl
	clean_rv_sbi
	clean_rv_kernel
	clean_rv_uroot
}

function build_rv_firmware_bin()
{
	build_rv_firmware

	gcc -g -Werror $RV_SCRIPTS_DIR/gen_spi_flash.c -o $RV_FIRMWARE_INSTALL_DIR/gen_spi_flash

	pushd $RV_FIRMWARE_INSTALL_DIR

	rm -f ./firmware.bin
	cp $RV_FIRMWARE/fip.bin  ./
	dtb_group=$(ls *.dtb | awk '{print ""$1" "$1" 0x020000000 "}')

	./gen_spi_flash $dtb_group \
			fw_jump.bin fw_jump.bin 0x00000000 \
			riscv64_Image riscv64_Image 0x02000000 \
			initrd.img initrd.img 0x30000000 \
			zsbl.bin zsbl.bin 0x40000000

	mv spi_flash.bin firmware.bin
	rm -f gen_spi_flash

	popd
}

function clean_rv_firmware_bin()
{
	clean_rv_firmware

	pushd $RV_FIRMWARE_INSTALL_DIR

	rm -f firmware.bin

	popd
}

function build_rv_firmware_image()
{
	build_rv_firmware

	pushd $RV_FIRMWARE_INSTALL_DIR

	rm -f firmware.img

	echo create an image file...
	dd if=/dev/zero of=firmware.img bs=256MiB count=1

	echo create partitions...
	sudo parted firmware.img mktable msdos
	sudo parted firmware.img mkpart p fat32 0% 100%
	loops=$(sudo kpartx -av firmware.img | cut -d ' ' -f 3)
	fat32part=$(echo $loops | cut -d ' ' -f 1)
	sudo mkfs.vfat /dev/mapper/$fat32part -n EFI

	echo mount EFI partition...
	sudo mkdir -p efi/
	sudo mount /dev/mapper/$fat32part efi
	sudo mkdir -p efi/riscv64

	echo copy bootloader...
	sudo cp $RV_FIRMWARE/fip.bin efi/
	sudo cp zsbl.bin efi/
	sudo cp riscv64_Image efi/riscv64
	sudo cp *.dtb efi/riscv64
	sudo cp initrd.img efi/riscv64
	sudo cp fw_jump.bin efi/riscv64
	sudo touch efi/BOOT

	echo cleanup...
	sudo umount /dev/mapper/$fat32part
	sudo kpartx -d $RV_FIRMWARE_INSTALL_DIR/firmware.img
	sudo rm -rf efi

	popd
}

function clean_rv_firmware_image()
{
	clean_rv_firmware

	pushd $RV_FIRMWARE_INSTALL_DIR

	rm -f firmware.img

	popd
}

function build_rv_firmware_package()
{
	build_rv_firmware

	pushd $RV_FIRMWARE_INSTALL_DIR

	mkdir -p firmware/riscv64

	echo copy bootloader...
	cp $RV_FIRMWARE/fip.bin firmware
	cp zsbl.bin firmware
	cp riscv64_Image firmware/riscv64
	cp *.dtb firmware/riscv64
	cp initrd.img firmware/riscv64
	cp fw_jump.bin firmware/riscv64
	touch firmware/BOOT

	tar -czvf firmware.tgz firmware
	rm -rf firmware

	popd
}

function clean_rv_firmware_package()
{
	clean_rv_firmware

	pushd $RV_FIRMWARE_INSTALL_DIR

	rm -f firmware.tgz

	popd
}

function build_rv_ltp()
{
	pushd $RV_LTP_SRC_DIR
	if [ ! -f "configure" ]; then
	    make autotools
	fi

	./configure CC=${RISCV64_LINUX_CROSS_COMPILE}gcc --prefix=$RV_LTP_OUTPUT_DIR --host=riscv64-linux-gnu  --without-tirpc
	make -j$(nproc) ARCH=riscv CROSS_COMPILE=${RISCV64_LINUX_CROSS_COMPILE}
	make install -j$(nproc)
	popd
}

function clean_rv_ltp()
{
	pushd $RV_LTP_SRC_DIR
	make clean
	rm -rf lib/newlib_tests/test_children_cleanup
	popd
	rm -rf $RV_LTP_OUTPUT_DIR
}

function build_rv_ubuntu()
{
	build_rv_ubuntu_kernel
	build_rv_ubuntu_perf_tool
	build_rv_ubuntu_distro
	build_rv_ubuntu_image
}

function clean_rv_ubuntu()
{
	clean_rv_ubuntu_kernel
	clean_rv_ubuntu_perf_tool
	clean_rv_ubuntu_distro
	clean_rv_ubuntu_image
}

function build_rv_fedora()
{
	build_rv_fedora_kernel
	build_rv_fedora_perf_tool
	build_rv_fedora_distro
	build_rv_fedora_image
}

function clean_rv_fedora()
{
	clean_rv_fedora_kernel
	clean_rv_fedora_perf_tool
	clean_rv_fedora_distro
	clean_rv_fedora_image
}

function build_rv_all()
{
	build_rv_firmware_bin
	build_rv_ubuntu
}

function clean_rv_all()
{
	clean_rv_firmware_bin
	clean_rv_ubuntu
}
