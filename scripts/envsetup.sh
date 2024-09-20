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

RV_BOOTROM_SRC_DIR=$RV_TOP_DIR/bootrom
RV_BOOTROM_BUILD_DIR=$RV_BOOTROM_SRC_DIR/build/$CHIP/$KERNEL_VARIANT

RV_ZSBL_SRC_DIR=$RV_TOP_DIR/zsbl
RV_ZSBL_BUILD_DIR=$RV_ZSBL_SRC_DIR/build/$CHIP/$KERNEL_VARIANT
RV_SBI_SRC_DIR=$RV_TOP_DIR/opensbi

RV_EDKII_SRC_DIR=$RV_TOP_DIR/sophgo-edk2
RV_UBOOT_SRC_DIR=$RV_TOP_DIR/u-boot
RV_GRUB_SRC_DIR=$RV_TOP_DIR/grub
RV_GRUB_BUILD_DIR=$RV_TOP_DIR/grubriscv64


RV_KERNEL_SRC_DIR=$RV_TOP_DIR/linux-riscv
RV_KERNEL_BUILD_DIR=$RV_KERNEL_SRC_DIR/build/$CHIP/$KERNEL_VARIANT
# RV_KERNEL_BUILD_DIR should only be used inside build/clean kernel functions

RV_RAMDISK_DIR=$RV_TOP_DIR/bootloader-riscv/ramdisk

RV_BUILDROOT_DIR=$RV_TOP_DIR/bootloader-riscv/buildroot
RV_UROOT_DIR=$RV_TOP_DIR/bootloader-riscv/u-root

RV_LTP_SRC_DIR=$RV_TOP_DIR/bsp-solutions/ltp
RV_LTP_OUTPUT_DIR=$RV_OUTPUT_DIR/ltp

TPUV7_RUNTIME_DIR=$RV_TOP_DIR/tpuv7-runtime
TPUV7_AP_DAEMON=$TPUV7_RUNTIME_DIR/build/asic/cdmlib/ap/daemon/cdm_daemon/cdm_daemon
TPUV7_TP_DAEMON=$TPUV7_RUNTIME_DIR/build/asic/cdmlib/tp/daemon/tp_daemon

RV_DISTRO_DIR=$RV_TOP_DIR/distro_riscv
RV_UBUNTU_DISTRO=ubuntu
RV_FEDORA_DISTRO=fedora
RV_EULER_DISTRO=euler

RV_UBUNTU_OFFICIAL_IMAGE=ubuntu-24.04.1-preinstalled-server-riscv64+unmatched.img
DOWNLOAD_RV_UBUNTU_OFFICIAL_IMAGE="wget https://cdimage.ubuntu.com/releases/noble/release/$RV_UBUNTU_OFFICIAL_IMAGE.xz"
UNCOMPRESS_RV_UBUNTU_OFFICIAL_IMAGE="unxz $RV_UBUNTU_OFFICIAL_IMAGE.xz"

RV_FEDORA_OFFICIAL_IMAGE=fedora-disk-server_sophgo_sg2042-f38-20230523-014306.n.0-sda.raw
DOWNLOAD_RV_FEDORA_OFFICIAL_IMAGE="wget http://openkoji.iscas.ac.cn/kojifiles/work/tasks/8061/1418061/$RV_FEDORA_OFFICIAL_IMAGE.xz"
UNCOMPRESS_RV_FEDORA_OFFICIAL_IMAGE="unxz $RV_FEDORA_OFFICIAL_IMAGE.xz"

RV_EULER_OFFICIAL_IMAGE=openEuler-24.03-V1-base-sg2042-testing.img
DOWNLOAD_RV_EULER_OFFICIAL_IMAGE="wget https://repo.tarsier-infra.isrc.ac.cn/openEuler-RISC-V/testing/20240708/v0.1/SG2042/$RV_EULER_OFFICIAL_IMAGE.zst"
UNCOMPRESS_RV_EULER_OFFICIAL_IMAGE="unzstd $RV_EULER_OFFICIAL_IMAGE.zst"

RV_UBUNTU_SOPHGO_IMAGE=ubuntu-sophgo.img
RV_FEDORA_SOPHGO_IMAGE=fedora-sophgo.img
RV_EULER_SOPHGO_IMAGE=euler-sophgo.img

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

if [ $HOST_ARCH = 'riscv64' ]; then
	RISCV64_LINUX_CROSS_COMPILE=
else
	RISCV64_LINUX_CROSS_COMPILE=$RV_LINUX_GCC_INSTALL_DIR/bin/riscv64-unknown-linux-gnu-
fi
RISCV64_ELF_CROSS_COMPILE=$RV_ELF_GCC_INSTALL_DIR/bin/riscv64-unknown-elf-

TP_IMAGES=(
	tp_zsbl.bin
	fw_dynamic.bin
	tp_Image.bin
	tp.dtb
	tp_rootfs.cpio
)

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
	echo "RV_EDKII_SRC_DIR: $RV_EDKII_SRC_DIR"
	echo "RV_KERNEL_SRC_DIR: $RV_KERNEL_SRC_DIR"
	echo "RV_KERNEL_BUILD_DIR: $RV_KERNEL_BUILD_DIR"
}

function show_rv_functions()
{
	echo "show_rv_env			-print build environment"
	echo "show_rv_functions     		-print all funtions "
	echo ""
	echo "build_rv_gcc			-build gcc from source"
	echo "build_rv_bootrom			-build bootrom bin"
	echo "build_rv_zsbl			-build zsbl bin"
	echo "build_rv_sbi			-build sbi bin"
	echo "build_rv_edk2			-build EDKII bin"
	echo "build_rv_uboot			-build u-boot bin"
	echo "build_rv_ubuntu_grub		-build ubuntu grub2 bin"
	echo "build_rv_fedora_grub		-build fedora grub2 bin"
	echo "build_rv_kernel			-build linuxboot kernel"
	echo "build_rv_ubuntu_kernel		-build ubuntu kernel"
	echo "build_rv_fedora_kernel		-build fedora kernel"
	echo "build_rv_euler_kernel		-build euler kernel"
	echo "build_rv_ramfs			-build buildroot"
	echo "build_rv_uroot			-build u-root for linuxboot"
	echo "build_rv_ltp			-build ltp"
	echo "build_rv_ubuntu_perf_tool     	-build ubuntu perf tool source package"
	echo "build_rv_fedora_perf_tool     	-build fedora perf tool source package"
	echo "build_rv_euler_perf_tool     	-build euler perf tool source package"
	echo "build_rv_firmware                 -build firmware(zsbl,sbi,edk2,kernel,uroot,uboot,grub2)"
	echo "build_rv_firmware_bin		-build firmware bin"
	echo "build_rv_firmware_image		-build firmware image"
	echo "build_rv_firmware_package 	-build firmware package"
	echo "build_rv_ubuntu_distro		-dowload ubuntu image from offical"
	echo "build_rv_fedora_distro		-download fedora image from offical"
	echo "build_rv_euler_distro		-download euler image from offical"
	echo "build_rv_ubuntu_image		-only build sophgo ubuntu image"
	echo "build_rv_fedora_image		-only build sophgo fedora image"
	echo "build_rv_euler_image		-only build sophgo euler image"
	echo "build_rv_ubuntu			-build sophgo ubuntu image"
	echo "build_rv_fedora			-build sophgo fedora image"
	echo "build_rv_euler			-build sophgo euler image"
	echo "build_rv_all			-build all bin and image(default: ubuntu)"
	echo "build_ap_ramfs			-build tpuv7 cdm ap rootfs"
	echo "build_tp_ramfs			-build tpuv7 cdm tp rootfs"
	echo "build_tpuv7_runtime		-build tpuv7 runtime for sdk"
	echo ""
	echo "clean_rv_gcc			-clean gcc obj files"
	echo "clean_rv_bootrom			-clean bootrom obj files"
	echo "clean_rv_zsbl			-clean zsbl obj files"
	echo "clean_rv_sbi			-clean sbi obj files"
	echo "clean_rv_edk2			-clean EDKII obj files"
	echo "clean_rv_uboot			-clean u-boot obj files"
	echo "clean_rv_ubuntu_grub	  	-clean ubuntu grub2 obj files"
	echo "clean_rv_fedora_grub	  	-clean fedora grub2 obj files"
	echo "clean_rv_kernel			-clean linuxboot kernel obj files"
	echo "clean_rv_ubuntu_kernel		-clean ubuntu kernel obj files"
	echo "clean_rv_fedora_kernel		-clean fedora kernel obj files"
	echo "clean_rv_euler_kernel		-clean euler kernel obj files"
	echo "clean_rv_ramfs			-clean buildroot obj files"
	echo "clean_rv_uroot			-clean uroot obj files"
	echo "clean_rv_ltp			-clean ltp obj files"
	echo "clean_rv_ubuntu_perf_tool     	-clean ubuntu perf tool files"
	echo "clean_rv_fedora_perf_tool     	-clean fedora perf tool files"
	echo "clean_rv_firmware                 -clean firmware(zsbl,sbi,edk2,kernel,uroot,uboot,grub2)"
	echo "clean_rv_firmware_bin		-clean firmware bin"
	echo "clean_rv_firmware_image		-clean firmware image"
	echo "clean_rv_firmware_package 	-clean firmware package"
	echo "clean_rv_ubuntu_distro		-clean ubuntu image"
	echo "clean_rv_fedora_distro		-clean fedora image"
	echo "clean_rv_euler_distro		-clean fedora image"
	echo "clean_rv_ubuntu_image		-clean ubuntu image"
	echo "clean_rv_fedora_image		-clean fedora image"
	echo "clean_rv_euler_image		-clean euler image"
	echo "clean_rv_ubuntu			-clean ubuntu image"
	echo "clean_rv_fedora			-clean feodra image"
	echo "clean_rv_all			-clean all bin and image(default: ubuntu)"
	echo "clean_tpuv7_runtime		-clean tpuv7 runtime for sdk"
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
	git checkout 2023.11.08
	./configure --prefix=$RV_LINUX_GCC_INSTALL_DIR
	make linux -j$(nproc)
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
	git checkout 2023.11.08
	./configure --with-cmodel=medany --with-arch=rv64imafdc --with-abi=lp64d --prefix=$RV_ELF_GCC_INSTALL_DIR
	make -j$(nproc)
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

function build_rv_bootrom()
{
	local err

	pushd $RV_BOOTROM_SRC_DIR
	if [ $CHIP == 'mango' ]; then
		make CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE O=$RV_BOOTROM_BUILD_DIR ARCH=riscv sg2042_defconfig
	else
		make CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE O=$RV_BOOTROM_BUILD_DIR ARCH=riscv ${CHIP}_defconfig
	fi
	err=$?
	popd

	if [ $err -ne 0 ]; then
		echo "making bootrom config failed"
		return $err
	fi

	pushd $RV_BOOTROM_BUILD_DIR
	make -j$(nproc) CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE ARCH=riscv
	err=$?
	popd

	if [ $err -ne 0 ]; then
		echo "making bootrom failed"
		return $err
	fi

	mkdir -p $RV_FIRMWARE_INSTALL_DIR

	cp $RV_BOOTROM_BUILD_DIR/bootrom.bin $RV_FIRMWARE_INSTALL_DIR
}

function clean_rv_bootrom()
{
	rm -rf $RV_FIRMWARE_INSTALL_DIR/bootrom.bin
	rm -rf $RV_BOOTROM_BUILD_DIR
}

function build_rv_tp_zsbl()
{
	local err

	pushd $RV_ZSBL_SRC_DIR
	make CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE O=$RV_ZSBL_BUILD_DIR ARCH=riscv bm1690_tpu_defconfig
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

	cp $RV_ZSBL_BUILD_DIR/zsbl.bin $RV_FIRMWARE_INSTALL_DIR/tp_zsbl.bin
}

function clean_rv_tp_zsbl()
{
	rm -rf $RV_FIRMWARE_INSTALL_DIR/tp_zsbl.bin
	rm -rf $RV_ZSBL_BUILD_DIR
}

function build_rv_zsbl()
{
	local err

	pushd $RV_ZSBL_SRC_DIR
	if [ $CHIP = 'mango' ]; then
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
	make -j$(nproc) CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE PLATFORM=$PLATFORM FW_PIC=y BUILD_INFO=y DEBUG=1
	popd

	mkdir -p $RV_FIRMWARE_INSTALL_DIR

	cp $RV_SBI_SRC_DIR/build/platform/$PLATFORM/firmware/fw_dynamic.bin $RV_FIRMWARE_INSTALL_DIR
	cp $RV_SBI_SRC_DIR/build/platform/$PLATFORM/firmware/fw_dynamic.elf $RV_FIRMWARE_INSTALL_DIR
}

function clean_rv_sbi()
{
	rm -rf $RV_FIRMWARE_INSTALL_DIR/fw_dynamic.*

	pushd $RV_SBI_SRC_DIR
	make distclean
	popd
}

function build_rv_edk2()
{
	pushd $RV_EDKII_SRC_DIR
	
	if [ $CHIP = 'mango' ]; then
		git submodule sync
		git submodule update --init --recursive

		export WORKSPACE=$RV_EDKII_SRC_DIR
		export PACKAGES_PATH=$WORKSPACE/edk2:$RV_EDKII_SRC_DIR/edk2-platforms:$RV_EDKII_SRC_DIR/edk2-non-osi
		export EDK_TOOLS_PATH=$WORKSPACE/edk2/BaseTools
		export GCC5_RISCV64_PREFIX=$RISCV64_ELF_CROSS_COMPILE

		source edk2/edksetup.sh

		make -C edk2/BaseTools -j$(nproc)

		if [ "$CHIP_NUM" = "multi" ];then
			TARGET=DEBUG
			build -a RISCV64 -t GCC5 -b $TARGET -p Platform/Sophgo/SG2042_EVB_Board/SG2042.dsc
		else
			TARGET=RELEASE
			build -a RISCV64 -t GCC5 -b $TARGET -D X64EMU_ENABLE -p Platform/Sophgo/SG2042_EVB_Board/SG2042.dsc
		fi

		mkdir -p $RV_FIRMWARE_INSTALL_DIR

		cp $RV_EDKII_SRC_DIR/Build/SG2042_EVB/$TARGET\_GCC5/FV/SG2042.fd $RV_FIRMWARE_INSTALL_DIR
	else
		git checkout devel-${CHIP}

		git submodule sync
		git submodule update --init --recursive

		export WORKSPACE=$RV_EDKII_SRC_DIR
		export PACKAGES_PATH=$WORKSPACE/edk2:$RV_EDKII_SRC_DIR/edk2-platforms:$RV_EDKII_SRC_DIR/edk2-non-osi:$WORKSPACE/external-modules
		export EDK_TOOLS_PATH=$WORKSPACE/edk2/BaseTools
		export GCC5_RISCV64_PREFIX=$RISCV64_ELF_CROSS_COMPILE

		source edk2/edksetup.sh

		make -C edk2/BaseTools -j$(nproc)

		git checkout devel-${CHIP}

		pushd edk2-platforms
		git checkout devel-${CHIP}
		popd

		pushd edk2-non-osi
		git checkout devel-${CHIP}
		popd

		pushd edk2
		git checkout devel-${CHIP}
		popd

		TARGET=RELEASE
		build -a RISCV64 -t GCC5 -b $TARGET -D X64EMU_ENABLE -p Platform/Sophgo/${CHIP^^}Pkg/${CHIP^^}.dsc

		mkdir -p $RV_FIRMWARE_INSTALL_DIR

		cp $RV_EDKII_SRC_DIR/Build/${CHIP^^}/$TARGET\_GCC5/FV/${CHIP^^}.fd $RV_FIRMWARE_INSTALL_DIR
	fi

	popd
}

function clean_rv_edk2()
{
	if [ $CHIP = 'mango' ]; then
		rm -rf $RV_FIRMWARE_INSTALL_DIR/SG2042.fd
	else
		rm -rf $RV_FIRMWARE_INSTALL_DIR/${CHIP^^}.fd
	fi

	pushd $RV_EDKII_SRC_DIR
	rm -rf Build
	pushd edk2/BaseTools
	make clean
	popd
	popd
}

function build_rv_uboot()
{
	pushd $RV_UBOOT_SRC_DIR
	make CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE ARCH=riscv sophgo_sg2042_defconfig
	make CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE ARCH=riscv all
	popd

	mkdir -p $RV_FIRMWARE_INSTALL_DIR

	cp $RV_UBOOT_SRC_DIR/u-boot.bin $RV_FIRMWARE_INSTALL_DIR
}

function clean_rv_uboot()
{
	rm -f $RV_FIRMWARE_INSTALL_DIR/u-boot.bin

	pushd $RV_UBOOT_SRC_DIR
	make distclean
	popd
}

function build_rv_ubuntu_grub()
{
	# setup build env
	GRUB_UBUNTU_INSTALL_DIR=${RV_GRUB_BUILD_DIR}/ubuntu-rootfs

	# make executable efi file
	mkdir -p $GRUB_UBUNTU_INSTALL_DIR

	pushd $RV_GRUB_SRC_DIR

	# bootstrap, download gunlib...
	./bootstrap
	# auto generate the config files
	./autogen.sh
	# auto config and generate Makefile
	TARGET_CC="${RISCV64_LINUX_CROSS_COMPILE}gcc" \
	TARGET_OBJCOPY="${RISCV64_LINUX_CROSS_COMPILE}objcopy" \
	TARGET_STRIP="${RISCV64_LINUX_CROSS_COMPILE}strip" \
	TARGET_NM="${RISCV64_LINUX_CROSS_COMPILE}nm" \
	TARGET_RANLIB="${RISCV64_LINUX_CROSS_COMPILE}ranlib" \
	TARGET_CFLAGS='-O2 -march=rv64imafdc_zicsr_zifencei' \
	./configure --target=riscv64-unknown-linux-gnu --with-platform=efi --prefix=$GRUB_UBUNTU_INSTALL_DIR
	# build and install to ${RISCV_ROOTFS}
	make install -j$(nproc)
	popd

	GRUB_UBUNTU_DEFAULT_CFG_RISCV=${RV_GRUB_BUILD_DIR}/ubuntu.cfg
	echo "search -f /boot/grub/grub.cfg -s root" > $GRUB_UBUNTU_DEFAULT_CFG_RISCV
	echo "set prefix=(\$root)'/boot/grub'" >> $GRUB_UBUNTU_DEFAULT_CFG_RISCV
	echo "configfile \$prefix/grub.cfg" >> $GRUB_UBUNTU_DEFAULT_CFG_RISCV

	GRUB_BINARY_NAME_RISCV=grubriscv64.efi
	GRUB_BINARY_FORMAT_RISCV=riscv64-efi
	GRUB_PREFIX_DIR_RISCV=efi
	GRUB_UEFI_IMAGE_MODULES_RISCV='acpi adler32 affs afs afsplitter all_video archelp bfs bitmap bitmap_scale blocklist boot bswap_test btrfs bufio cat cbfs chain cmdline_cat_test cmp cmp_test configfile cpio_be cpio crc64 cryptodisk crypto ctz_test datehook date datetime diskfilter disk div div_test dm_nv echo efifwsetup efi_gop efinet elf eval exfat exfctest ext2 extcmd f2fs fat fdt file font fshelp functional_test gcry_arcfour gcry_blowfish gcry_camellia gcry_cast5 gcry_crc gcry_des gcry_dsa gcry_idea gcry_md4 gcry_md5 gcry_rfc2268 gcry_rijndael gcry_rmd160 gcry_rsa gcry_seed gcry_serpent gcry_sha1 gcry_sha256 gcry_sha512 gcry_tiger gcry_twofish gcry_whirlpool geli gettext gfxmenu gfxterm_background gfxterm_menu gfxterm gptsync gzio halt hashsum hello help hexdump hfs hfspluscomp hfsplus http iso9660 jfs jpeg json keystatus ldm linux loadenv loopback lsacpi lsefimmap lsefi lsefisystab lsmmap ls lssal luks2 luks lvm lzopio macbless macho mdraid09_be mdraid09 mdraid1x memdisk memrw minicmd minix2_be minix2 minix3_be minix3 minix_be minix mmap mpi msdospart mul_test net newc nilfs2 normal ntfscomp ntfs odc offsetio part_acorn part_amiga part_apple part_bsd part_dfly part_dvh part_gpt part_msdos part_plan part_sun part_sunpc parttool password password_pbkdf2 pbkdf2 pbkdf2_test pgp png priority_queue probe procfs progress raid5rec raid6rec read reboot regexp reiserfs romfs scsi search_fs_file search_fs_uuid search_label search serial setjmp setjmp_test sfs shift_test signature_test sleep sleep_test smbios squash4 strtoull_test syslinuxcfg tar terminal terminfo test_blockarg testload test testspeed tftp tga time tpm trig tr true udf ufs1_be ufs1 ufs2 video_colors video_fb videoinfo video videotest_checksum videotest xfs xnu_uuid xnu_uuid_test xzio zfscrypt zfsinfo zfs zstd'

	pushd ${GRUB_UBUNTU_INSTALL_DIR}


	./bin/grub-mkimage -v \
		-o ${GRUB_BINARY_NAME_RISCV} \
		-O ${GRUB_BINARY_FORMAT_RISCV} \
		-p ${GRUB_PREFIX_DIR_RISCV}  \
		-c ${GRUB_UBUNTU_DEFAULT_CFG_RISCV} ${GRUB_UEFI_IMAGE_MODULES_RISCV}
	popd

	mkdir -p $RV_FIRMWARE_INSTALL_DIR

	cp -r $RV_GRUB_BUILD_DIR $RV_FIRMWARE_INSTALL_DIR
}

function build_rv_fedora_grub()
{
	# setup build env
	GRUB_FEDORA_INSTALL_DIR=${RV_GRUB_BUILD_DIR}/fedora-rootfs

	# make executable efi file
	mkdir -p $GRUB_FEDORA_INSTALL_DIR

	pushd $RV_GRUB_SRC_DIR

	# bootstrap, download gunlib...
	./bootstrap
	# auto generate the config files
	./autogen.sh
	# auto config and generate Makefile
	TARGET_CC="${RISCV64_LINUX_CROSS_COMPILE}gcc" \
	TARGET_OBJCOPY="${RISCV64_LINUX_CROSS_COMPILE}objcopy" \
	TARGET_STRIP="${RISCV64_LINUX_CROSS_COMPILE}strip" \
	TARGET_NM="${RISCV64_LINUX_CROSS_COMPILE}nm" \
	TARGET_RANLIB="${RISCV64_LINUX_CROSS_COMPILE}ranlib" \
	TARGET_CFLAGS='-O2 -march=rv64imafdc_zicsr_zifencei' \
	./configure --target=riscv64-unknown-linux-gnu --with-platform=efi --prefix=$GRUB_FEDORA_INSTALL_DIR
	# build and install to ${RISCV_ROOTFS}
	make install -j$(nproc)
	popd

	GRUB_FEDORA_DEFAULT_CFG_RISCV=${RV_GRUB_BUILD_DIR}/fedora.cfg
	echo "search -f /grub2/grub.cfg -s root" > $GRUB_FEDORA_DEFAULT_CFG_RISCV
	echo "set prefix=(\$root)'/grub2'" >> $GRUB_FEDORA_DEFAULT_CFG_RISCV
	echo "configfile \$prefix/grub.cfg" >> $GRUB_FEDORA_DEFAULT_CFG_RISCV

	GRUB_BINARY_NAME_RISCV=grubriscv64.efi
	GRUB_BINARY_FORMAT_RISCV=riscv64-efi
	GRUB_PREFIX_DIR_RISCV=efi
	GRUB_UEFI_IMAGE_MODULES_RISCV='acpi adler32 affs afs afsplitter all_video archelp bfs bitmap bitmap_scale blocklist boot bswap_test btrfs bufio cat cbfs chain cmdline_cat_test cmp cmp_test configfile cpio_be cpio crc64 cryptodisk crypto ctz_test datehook date datetime diskfilter disk div div_test dm_nv echo efifwsetup efi_gop efinet elf eval exfat exfctest ext2 extcmd f2fs fat fdt file font fshelp functional_test gcry_arcfour gcry_blowfish gcry_camellia gcry_cast5 gcry_crc gcry_des gcry_dsa gcry_idea gcry_md4 gcry_md5 gcry_rfc2268 gcry_rijndael gcry_rmd160 gcry_rsa gcry_seed gcry_serpent gcry_sha1 gcry_sha256 gcry_sha512 gcry_tiger gcry_twofish gcry_whirlpool geli gettext gfxmenu gfxterm_background gfxterm_menu gfxterm gptsync gzio halt hashsum hello help hexdump hfs hfspluscomp hfsplus http iso9660 jfs jpeg json keystatus ldm linux loadenv loopback lsacpi lsefimmap lsefi lsefisystab lsmmap ls lssal luks2 luks lvm lzopio macbless macho mdraid09_be mdraid09 mdraid1x memdisk memrw minicmd minix2_be minix2 minix3_be minix3 minix_be minix mmap mpi msdospart mul_test net newc nilfs2 normal ntfscomp ntfs odc offsetio part_acorn part_amiga part_apple part_bsd part_dfly part_dvh part_gpt part_msdos part_plan part_sun part_sunpc parttool password password_pbkdf2 pbkdf2 pbkdf2_test pgp png priority_queue probe procfs progress raid5rec raid6rec read reboot regexp reiserfs romfs scsi search_fs_file search_fs_uuid search_label search serial setjmp setjmp_test sfs shift_test signature_test sleep sleep_test smbios squash4 strtoull_test syslinuxcfg tar terminal terminfo test_blockarg testload test testspeed tftp tga time tpm trig tr true udf ufs1_be ufs1 ufs2 video_colors video_fb videoinfo video videotest_checksum videotest xfs xnu_uuid xnu_uuid_test xzio zfscrypt zfsinfo zfs zstd'

	pushd ${GRUB_FEDORA_INSTALL_DIR}


	./bin/grub-mkimage -v \
		-o ${GRUB_BINARY_NAME_RISCV} \
		-O ${GRUB_BINARY_FORMAT_RISCV} \
		-p ${GRUB_PREFIX_DIR_RISCV}  \
		-c ${GRUB_FEDORA_DEFAULT_CFG_RISCV} ${GRUB_UEFI_IMAGE_MODULES_RISCV}
	popd

	mkdir -p $RV_FIRMWARE_INSTALL_DIR

	cp -r $RV_GRUB_BUILD_DIR $RV_FIRMWARE_INSTALL_DIR
}

function clean_rv_ubuntu_grub()
{
	rm -rf $RV_FIRMWARE_INSTALL_DIR/grubriscv64
	rm -rf $RV_GRUB_BUILD_DIR

	pushd $RV_GRUB_SRC_DIR
	make distclean
	popd
}

function clean_rv_fedora_grub()
{
	rm -rf $RV_FIRMWARE_INSTALL_DIR/grubriscv64
	rm -rf $RV_GRUB_BUILD_DIR

	pushd $RV_GRUB_SRC_DIR
	make distclean
	popd
}

function build_rv_kernel()
{
	local RV_KERNEL_CONFIG=${VENDOR}_${CHIP}_${KERNEL_VARIANT}_defconfig
	local err

	if [ "$CHIP" = "bm1690" ];then
		if [ "$1" = "" ];then
			echo "build bm1690 kernel, eg: build_rv_kernel ap|tp"
			return -1
		fi
		RV_KERNEL_CONFIG=${VENDOR}_${CHIP}_$1_${KERNEL_VARIANT}_defconfig
		RV_KERNEL_BUILD_DIR=$RV_KERNEL_SRC_DIR/build/$CHIP/$1_${KERNEL_VARIANT}
	fi

	pushd $RV_KERNEL_SRC_DIR
	make O=$RV_KERNEL_BUILD_DIR ARCH=riscv CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE $RV_KERNEL_CONFIG
	err=$?
	popd

	if [ $err -ne 0 ]; then
		echo "making kernel config failed"
		return $err
	fi

	pushd $RV_KERNEL_BUILD_DIR
	if [ "$CHIP_NUM" = "multi" ];then
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
	if [ "$CHIP" = "bm1690" ];then
		cp $RV_KERNEL_BUILD_DIR/arch/riscv/boot/Image $RV_FIRMWARE_INSTALL_DIR/$1_Image
	else
		cp $RV_KERNEL_BUILD_DIR/arch/riscv/boot/Image $RV_FIRMWARE_INSTALL_DIR/riscv64_Image
	fi

	if [ $CHIP != 'qemu' ]; then
	    cp $RV_KERNEL_BUILD_DIR/arch/riscv/boot/dts/sophgo/*.dtb $RV_FIRMWARE_INSTALL_DIR
	fi
}

function clean_rv_kernel()
{
	rm -rf $RV_FIRMWARE_INSTALL_DIR/*_Image
	rm -rf $RV_FIRMWARE_INSTALL_DIR/vmlinux
	rm -rf $RV_FIRMWARE_INSTALL_DIR/*.dtb

	if [ "$CHIP" = "bm1690" ];then
		rm -rf $RV_KERNEL_SRC_DIR/build/$CHIP/*${KERNEL_VARIANT}
	else
		rm -rf $RV_KERNEL_BUILD_DIR
	fi
}

function build_rv_ubuntu_kernel()
{
	local RV_KERNEL_CONFIG=${VENDOR}_${CHIP}_ubuntu_defconfig
	local err
	RV_KERNEL_BUILD_DIR=$RV_KERNEL_SRC_DIR/build/$CHIP/ubuntu

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

	if [ "$CHIP_NUM" = "multi" ];then
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
	RV_KERNEL_BUILD_DIR=$RV_KERNEL_SRC_DIR/build/$CHIP/ubuntu
	rm -rf $RV_KERNEL_BUILD_DIR
	rm -f $RV_DEB_INSTALL_DIR/linux-*.deb
}

function build_rv_fedora_kernel()
{
	local RV_KERNEL_CONFIG=${VENDOR}_${CHIP}_fedora_defconfig
	local KERNELRELEASE
	local RPMBUILD_DIR
	local err
	RV_KERNEL_BUILD_DIR=$RV_KERNEL_SRC_DIR/build/$CHIP/fedora

	pushd $RV_KERNEL_SRC_DIR
	make ARCH=riscv CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE $RV_KERNEL_CONFIG
	err=$?
	if [ $err -ne 0 ]; then
		echo "making kernel config failed"
		popd
		return $err
	fi

	if [ "$CHIP_NUM" = "multi" ];then
		sed -i 's/# CONFIG_SOPHGO_MULTI_CHIP_CLOCK_SYNC is not set/CONFIG_SOPHGO_MULTI_CHIP_CLOCK_SYNC=y/' .config
	fi

	if [ -e ~/.rpmmacros ]; then
		mv ~/.rpmmacros ~/.rpmmacros.orig
	fi

# following lines must not be started with space or tab.
cat >> ~/.rpmmacros << "EOT"
%_build_name_fmt        %%{ARCH}/%%{NAME}-%%{VERSION}.%%{ARCH}.rpm
EOT

	KERNELRELEASE=$(make ARCH=riscv LOCALVERSION="" kernelrelease)
	if [[ ${KERNELRELEASE:0:3} == "6.1" ]]; then
		RPMBUILD_DIR=$HOME/rpmbuild
	else
		RPMBUILD_DIR=$RV_KERNEL_SRC_DIR/rpmbuild
	fi

	make -j$(nproc) ARCH=riscv CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE LOCALVERSION="" rpm-pkg
	ret=$?
	rm ~/.rpmmacros
	if [ -e ~/.rpmmacros.orig ]; then
		mv ~/.rpmmacros.orig ~/.rpmmacros
	fi
	if [ $ret -ne 0 ]; then
		echo "making rpm package failed"
		make ARCH=riscv CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE distclean
		rm *.tar.gz
		rm -rf $RPMBUILD_DIR
		popd
		return $ret
	fi

	if [ ! -d $RV_RPM_INSTALL_DIR ]; then
		mkdir -p $RV_RPM_INSTALL_DIR
	else
		rm -f $RV_RPM_INSTALL_DIR/kernel-*.rpm
	fi

	cp $RPMBUILD_DIR/RPMS/riscv64/*.rpm $RV_RPM_INSTALL_DIR/
	make ARCH=riscv CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE distclean
	rm *.tar.gz
	rm -rf $RPMBUILD_DIR
	popd
}

function clean_rv_fedora_kernel()
{
	RV_KERNEL_BUILD_DIR=$RV_KERNEL_SRC_DIR/build/$CHIP/fedora
	pushd $RV_KERNEL_SRC_DIR
	make distclean
	popd
	rm -f $RV_RPM_INSTALL_DIR/kernel-*.rpm
}

function build_rv_euler_kernel()
{
	local RV_KERNEL_CONFIG=${VENDOR}_${CHIP}_openeuler_defconfig
	local KERNELRELEASE
	local RPMBUILD_DIR
	local err
	RV_KERNEL_BUILD_DIR=$RV_KERNEL_SRC_DIR/build/$CHIP/euler

	pushd $RV_KERNEL_SRC_DIR
	make ARCH=riscv CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE $RV_KERNEL_CONFIG
	err=$?
	if [ $err -ne 0 ]; then
		echo "making kernel config failed"
		popd
		return $err
	fi

	if [ "$CHIP_NUM" = "multi" ];then
		sed -i 's/# CONFIG_SOPHGO_MULTI_CHIP_CLOCK_SYNC is not set/CONFIG_SOPHGO_MULTI_CHIP_CLOCK_SYNC=y/' .config
	fi

	if [ -e ~/.rpmmacros ]; then
		mv ~/.rpmmacros ~/.rpmmacros.orig
	fi

# following lines must not be started with space or tab.
cat >> ~/.rpmmacros << "EOT"
%_build_name_fmt        %%{ARCH}/%%{NAME}-%%{VERSION}.%%{ARCH}.rpm
EOT

	KERNELRELEASE=$(make ARCH=riscv LOCALVERSION="" kernelrelease)
	if [[ ${KERNELRELEASE:0:3} == "6.1" ]]; then
		RPMBUILD_DIR=$HOME/rpmbuild
	else
		RPMBUILD_DIR=$RV_KERNEL_SRC_DIR/rpmbuild
	fi

	make -j$(nproc) ARCH=riscv CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE LOCALVERSION="" rpm-pkg
	ret=$?
	rm ~/.rpmmacros
	if [ -e ~/.rpmmacros.orig ]; then
		mv ~/.rpmmacros.orig ~/.rpmmacros
	fi
	if [ $ret -ne 0 ]; then
		echo "making rpm package failed"
		make ARCH=riscv CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE distclean
		rm *.tar.gz
		rm -rf $RPMBUILD_DIR
		popd
		return $ret
	fi

	if [ ! -d $RV_RPM_INSTALL_DIR ]; then
		mkdir -p $RV_RPM_INSTALL_DIR
	else
		rm -f $RV_RPM_INSTALL_DIR/kernel-*.rpm
	fi

	cp $RPMBUILD_DIR/RPMS/riscv64/*.rpm $RV_RPM_INSTALL_DIR/
	make ARCH=riscv CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE distclean
	rm *.tar.gz
	rm -rf $RPMBUILD_DIR
	popd
}

function clean_rv_euler_kernel()
{
	RV_KERNEL_BUILD_DIR=$RV_KERNEL_SRC_DIR/build/$CHIP/euler
	pushd $RV_KERNEL_SRC_DIR
	make distclean
	popd
	rm -f $RV_RPM_INSTALL_DIR/kernel-*.rpm
}

RAMDISK_CPU_TYPES=(
ap
rp
tp
)

function build_rv_ramdisk()
{
	for i in ${RAMDISK_CPU_TYPES[@]}
	do
		if [ "$i" == "$1" ]; then
			local RAMDISK_CPU_TYPE=$1
		fi
	done
	if [ -z "$RAMDISK_CPU_TYPE" ]; then
		echo please specify a ramdisk type:
		for i in ${RAMDISK_CPU_TYPES[@]}
		do
			echo -e "\t $i"
		done
		return
	fi
	echo build ramdisk for $RAMDISK_CPU_TYPE

	rm -rf $RV_RAMDISK_DIR/build/$RAMDISK_CPU_TYPE
	mkdir -p $RV_RAMDISK_DIR/build/$RAMDISK_CPU_TYPE/rootfs
	cp -rf $RV_RAMDISK_DIR/rootfs_202405/* $RV_RAMDISK_DIR/build/$RAMDISK_CPU_TYPE/rootfs
	cp -rf $RV_RAMDISK_DIR/overlay/$RAMDISK_CPU_TYPE/* $RV_RAMDISK_DIR/build/$RAMDISK_CPU_TYPE/rootfs

	if [ "tp" == $RAMDISK_CPU_TYPE ]; then
		# copy tp daemon
		if [ -f $TPUV7_TP_DAEMON ]; then
			cp $TPUV7_TP_DAEMON $RV_RAMDISK_DIR/build/$RAMDISK_CPU_TYPE/rootfs/
		else
			echo "no ap daemon found"
		fi
		# copy other non-generated files
		if [ -d $TPUV7_RUNTIME_DIR/cdmlib/overlay/tp ]; then
			echo "copy cdmlib overlay tp all to rootfs/tpu"
			cp $TPUV7_RUNTIME_DIR/cdmlib/overlay/tp/* $RV_RAMDISK_DIR/build/tp/rootfs/tpu/
		fi
	fi
	if [ "ap" == $RAMDISK_CPU_TYPE ]; then
		if [ -f $TPUV7_AP_DAEMON ]; then
			echo "copy cdmlib overlay ap all to rootfs/"
			cp $TPUV7_AP_DAEMON $RV_RAMDISK_DIR/build/$RAMDISK_CPU_TYPE/rootfs/
		else
			echo "no ap daemon found"
		fi
	fi


	pushd $RV_RAMDISK_DIR/build/$RAMDISK_CPU_TYPE/rootfs
	find . | cpio -o -H newc > ../$RAMDISK_CPU_TYPE\_rootfs.cpio
	cp ../$RAMDISK_CPU_TYPE\_rootfs.cpio $RV_FIRMWARE_INSTALL_DIR

	popd
}

function clean_rv_ramdisk()
{
	for i in ${RAMDISK_CPU_TYPES[@]}
	do
		if [ "$i" == "$1" ]; then
		local RAMDISK_CPU_TYPE=$1
	fi
	done
	if [ -z "$RAMDISK_CPU_TYPE" ]; then
		echo please specify a ramdisk type:
		for i in ${RAMDISK_CPU_TYPES[@]}
		do
			echo -e "\t $i"
		done
		return
	fi
	rm -rf $RV_RAMDISK_DIR/build/$RAMDISK_CPU_TYPE
	rm -rf $RV_FIRMWARE_INSTALL_DIR/$RAMDISK_CPU_TYPE\_rootfs.cpio
}

function build_tp_ramfs()
{
	if [ ! -d $RV_BUILDROOT_DIR/overlay/tp ]; then
		mkdir -p $RV_BUILDROOT_DIR/overlay/tp
	fi

	# copy tp daemon
	if [ -f $TPUV7_TP_DAEMON ]; then
		cp $TPUV7_TP_DAEMON $RV_BUILDROOT_DIR/overlay/tp/
	else
		echo "no ap daemon found"
	fi

	# copy other non-generated files
	cp $TPUV7_RUNTIME_DIR/cdmlib/overlay/tp/* $RV_BUILDROOT_DIR/overlay/tp/

	pushd $RV_BUILDROOT_DIR
	make sg2260_tp_defconfig
	err=$?
	popd

	if [ $err -ne 0 ]; then
	    echo 'config buildroot failed'
	    return $err
	fi

	pushd $RV_BUILDROOT_DIR
	make -j$(nproc)
	err=$?
	popd

	if [ $err -ne 0 ]; then
	    echo 'build buildroot failed'
	    return $err
	fi

	cp $RV_BUILDROOT_DIR/output/images/rootfs.cpio $RV_FIRMWARE_INSTALL_DIR/tp_rootfs.cpio

	# delete tp daemon
	rm $RV_BUILDROOT_DIR/output/target/tp_daemon

	# delete other non-generated files
	pushd $RV_BUILDROOT_DIR/overlay/tp/
	TP_OVERLAY_FILE=$(find ./)
	popd

	pushd $RV_BUILDROOT_DIR/output/target/
	for i in ${TP_OVERLAY_FILE}; do
		if [ -f $i ]; then
			echo "dele $i"
			rm $i
		fi
	done
	popd
}

function clean_tp_ramfs()
{
	if [ -d $RV_BUILDROOT_DIR/overlay ]; then
		rm -rf $RV_BUILDROOT_DIR/overlay
	fi
}

function build_ap_ramfs()
{
	if [ ! -d $RV_BUILDROOT_DIR/overlay/ap ]; then
		mkdir -p $RV_BUILDROOT_DIR/overlay/ap
	fi

	# copy ap daemon
	if [ -f $TPUV7_AP_DAEMON ]; then
		cp $TPUV7_AP_DAEMON $RV_BUILDROOT_DIR/overlay/ap/
	else
		echo "no ap daemon found"
	fi

	# copy tp firmware file
	mkdir -p $RV_BUILDROOT_DIR/overlay/ap/lib/firmware/
	for i in ${TP_IMAGES[@]}; do
		if [ -f $RV_FIRMWARE_INSTALL_DIR/$i ]; then
			cp $RV_FIRMWARE_INSTALL_DIR/$i $RV_BUILDROOT_DIR/overlay/ap/lib/firmware/
		else
			echo "no $RV_FIRMWARE_INSTALL_DIR/$i found"
		fi
	done

	# copy other non-generated files
	cp $TPUV7_RUNTIME_DIR/cdmlib/overlay/ap/* $RV_BUILDROOT_DIR/overlay/ap/

	# package rootfs
	pushd $RV_BUILDROOT_DIR
	make sg2260_ap_defconfig
	err=$?
	popd

	if [ $err -ne 0 ]; then
	    echo 'config buildroot failed'
	    return $err
	fi

	pushd $RV_BUILDROOT_DIR
	make -j$(nproc)
	err=$?
	popd

	if [ $err -ne 0 ]; then
	    echo 'build buildroot failed'
	    return $err
	fi

	cp $RV_BUILDROOT_DIR/output/images/rootfs.cpio $RV_FIRMWARE_INSTALL_DIR/ap_rootfs.cpio

	# delete ap daemon
	if [ -f $RV_BUILDROOT_DIR/output/target/cdm_daemon ]; then
		rm $RV_BUILDROOT_DIR/output/target/cdm_daemon
	fi

	# delete tp firmware
	if [ -d $RV_BUILDROOT_DIR/output/target/lib/firmware ]; then
		rm -r $RV_BUILDROOT_DIR/output/target/lib/firmware
	fi

	# delete other non-generated files
	pushd $RV_BUILDROOT_DIR/overlay/ap/
	AP_OVERLAY_FILE=$(find ./)
	popd

	pushd $RV_BUILDROOT_DIR/output/target/
	for i in ${AP_OVERLAY_FILE}; do
		if [ -f $i ]; then
			echo "dele $i"
			rm $i
		fi
	done
	popd
}

function clean_ap_ramfs()
{
	if [ -d $RV_BUILDROOT_DIR/overlay ]; then
		rm -rf $RV_BUILDROOT_DIR/overlay
	fi
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
	pushd $RV_BUILDROOT_DIR
	make clean
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

function build_rv_euler_distro()
{
	mkdir -p $RV_DISTRO_DIR/$RV_EULER_DISTRO

	pushd $RV_DISTRO_DIR/$RV_EULER_DISTRO
	if [ ! -f $RV_EULER_OFFICIAL_IMAGE ] ; then
		$DOWNLOAD_RV_EULER_OFFICIAL_IMAGE
		$UNCOMPRESS_RV_EULER_OFFICIAL_IMAGE
	fi
	popd
}

function clean_rv_euler_distro()
{
	rm $RV_DISTRO_DIR/$RV_EULER_DISTRO/$RV_EULER_OFFICIAL_IMAGE
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
apt-mark hold linux-image-6.5.5
cat > /etc/modprobe.d/sg2042-blacklist.conf << EOF
blacklist switchtec
EOF

# replace UUID to LABEL
mv /etc/fstab /etc/fstab_bak
cat > /etc/fstab << EOF
LABEL=cloudimg-rootfs	/		ext4	defaults,discard,errors=remount-ro 0 1
LABEL=EFI		/boot/efi	vfat    defaults,discard,errors=remount-ro 0 1
EOF
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
	mkdir $RV_OUTPUT_DIR/root
	sudo mount /dev/mapper/$root_part $RV_OUTPUT_DIR/root

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

exit

EOT
	popd

	echo cleanup...
	sync
	sleep 60
	sudo rm $RV_OUTPUT_DIR/root/etc/hosts
	sudo mv $RV_OUTPUT_DIR/root/etc/hosts-bak $RV_OUTPUT_DIR/root/etc/hosts
	sudo umount $RV_OUTPUT_DIR/root/run
	sudo umount $RV_OUTPUT_DIR/root/proc
	sudo umount $RV_OUTPUT_DIR/root/sys
	sudo umount $RV_OUTPUT_DIR/root/dev/pts
	sudo umount $RV_OUTPUT_DIR/root/dev
	sudo umount /dev/mapper/$efi_part
	sudo umount /dev/mapper/$root_part
	sudo kpartx -d $RV_OUTPUT_DIR/$RV_EULER_SOPHGO_IMAGE
	sudo kpartx -d $RV_DISTRO_DIR/$RV_EULER_DISTRO/$RV_EULER_OFFICIAL_IMAGE
	sudo rm -r $RV_OUTPUT_DIR/efi
	#sudo umount $RV_OUTPUT_DIR/root
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
	mkdir $RV_OUTPUT_DIR/efi
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

function build_rv_euler_perf_tool()
{
	echo "build_rv_euler_perf_tool is not implemented"
}

function clean_rv_euler_perf_tool()
{
	echo "clean_rv_euler_perf_tool is not implemented"
}

function build_rv_firmware()
{
	build_rv_zsbl
	build_rv_sbi
	if [ "$CHIP" = "bm1690" ];then
		build_rv_kernel ap
		build_rv_kernel tp
	else
		build_rv_kernel
		build_rv_edk2
	fi

	build_rv_uroot
}

function clean_rv_firmware()
{
	clean_rv_zsbl
	clean_rv_sbi
	clean_rv_edk2
	clean_rv_kernel
	clean_rv_uroot
}

function build_rv_firmware_bin()
{
	version=$(date "+%Y%m%d%H%M%S")
	build_rv_firmware

	gcc -g -Werror $RV_SCRIPTS_DIR/gen_spi_flash.c -o $RV_FIRMWARE_INSTALL_DIR/gen_spi_flash

	pushd $RV_FIRMWARE_INSTALL_DIR

	rm -f firmware*.bin
	cp $RV_FIRMWARE/fip.bin  ./
	dtb_group=$(ls *.dtb | awk '{print ""$1" "$1" 0x601000 0x020000000 "}')

	./gen_spi_flash $dtb_group \
			fw_dynamic.bin fw_dynamic.bin 0x660000 0x00000000 \
			riscv64_Image riscv64_Image 0x6b0000 0x02000000 \
			SG2042.fd SG2042.fd 0x02000000 0x02000000 \
			zsbl.bin zsbl.bin 0x2a00000 0x40000000 \
			initrd.img initrd.img 0x2b00000 0x30000000

	mv spi_flash.bin firmware-$version.bin
	rm -f gen_spi_flash

	cp firmware-$version.bin image-bmc
	$RV_SCRIPTS_DIR/gen-tar-for-bmc.sh image-bmc -o obmc-bios.tar.gz -m ast2600-sophgo -v $version -s
	rm -f image-bmc

	popd
}

function clean_rv_firmware_bin()
{
	clean_rv_firmware

	pushd $RV_FIRMWARE_INSTALL_DIR

	rm -f firmware*.bin
	rm -f obmc-bios.tar.gz

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
	if [[ "$CHIP" = "sg2044" || "$CHIP" = "bm1690" ]];then
	sudo cp $RV_FIRMWARE/fsbl.bin efi/riscv64
	sudo cp zsbl.bin efi/riscv64
	else
	sudo cp $RV_FIRMWARE/fip.bin efi/
	sudo cp zsbl.bin efi/
	fi
	sudo cp riscv64_Image efi/riscv64
	sudo cp *.dtb efi/riscv64
	sudo cp initrd.img efi/riscv64
	sudo cp fw_dynamic.bin efi/riscv64
	# sudo cp uboot.bin efi/riscv64
	sudo cp SG2042.fd efi/riscv64
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
	if [[ "$CHIP" = "sg2044" || "$CHIP" = "bm1690" ]];then
	cp $RV_FIRMWARE/fsbl.bin firmware/riscv64
	cp zsbl.bin firmware/riscv64
	else
	cp $RV_FIRMWARE/fip.bin firmware
	cp zsbl.bin firmware
	fi
	# cp u-boot.bin firmware/riscv64
	cp SG2042.fd firmware/riscv64
	cp riscv64_Image firmware/riscv64
	cp *.dtb firmware/riscv64
	cp initrd.img firmware/riscv64
	cp fw_dynamic.bin firmware/riscv64
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

function build_rv_euler()
{
	build_rv_euler_kernel
	build_rv_euler_perf_tool
	build_rv_euler_distro
	build_rv_euler_image
}

function clean_rv_euler()
{
	clean_rv_euler_kernel
	clean_rv_euler_perf_tool
	clean_rv_euler_distro
	clean_rv_euler_image
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

function build_tpuv7_runtime()
{
	mkdir -p $TPUV7_RUNTIME_DIR/build/asic
	pushd $TPUV7_RUNTIME_DIR/build/asic
	cmake -DCMAKE_INSTALL_PREFIX=$PWD/../install  -DUSING_CMODEL=OFF ../..
	make -j$(nproc)
	popd

	mkdir -p $TPUV7_RUNTIME_DIR/build/emulator
	pushd $TPUV7_RUNTIME_DIR/build/emulator
	cmake -DCMAKE_INSTALL_PREFIX=$PWD/../install  -DUSING_CMODEL=ON ../..
	make -j$(nproc)
	popd
}

function clean_tpuv7_runtime()
{
	if [ -d $TPUV7_RUNTIME_DIR/build]; then
		rm $TPUV7_RUNTIME_DIR/build
	fi
}

# include top mcu environment
RV_TOP_MCU_BOOTLOADER_DIR=$RV_TOP_DIR/sophgo-2260
if [ -f $RV_TOP_MCU_BOOTLOADER_DIR/scripts/envsetup.sh ]; then
	echo 'import riscv top mcu build instructions'
	source $RV_TOP_MCU_BOOTLOADER_DIR/scripts/envsetup.sh
fi
