#!/bin/bash

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

function show_rv_env()
{
    echo "CHIP: $CHIP"
    echo "KERNEL_VARIANT: $KERNEL_VARIANT"
    echo "PLD_INSTALL_DIR: $PLD_INSTALL_DIR"
    echo "VENDOR: $VENDOR"
    echo "RISCV64_LINUX_CROSS_COMPILE: $RISCV64_LINUX_CROSS_COMPILE"
    echo "RISCV64_ELF_CROSS_COMPILE: $RISCV64_ELF_CROSS_COMPILE"
    echo "RV_TOP_DIR: $RV_TOP_DIR"
    echo "RV_OUTPUT_DIR: $RV_OUTPUT_DIR"
    echo "RV_SCRIPTS_DIR: $RV_SCRIPTS_DIR"
    echo "RV_KERNEL_SRC_DIR: $RV_KERNEL_SRC_DIR"
    echo "RV_KERNEL_BUILD_DIR: $RV_KERNEL_BUILD_DIR"
    echo "RV_BUILDROOT_DIR: $RV_BUILDROOT_DIR"
    echo "RV_SBI_DIR: $RV_SBI_DIR"
}

function build_rv_sbi()
{
    local SBI_PLAT=$VENDOR/$CHIP

    pushd $RV_SBI_DIR
    make -j$(nproc) PLATFORM=$SBI_PLAT CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE FW_TEXT_START=0x0 FW_JUMP_ADDR=0x00200000
    popd

    mkdir -p $RV_OUTPUT_DIR

    cp $RV_SBI_DIR/build/platform/$SBI_PLAT/firmware/fw_jump.bin $RV_OUTPUT_DIR
    cp $RV_SBI_DIR/build/platform/$SBI_PLAT/firmware/fw_jump.elf $RV_OUTPUT_DIR
}

function clean_rv_sbi()
{
    rm -rf $RV_OUTPUT_DIR/fw_jump.*

    pushd $RV_SBI_DIR
    make distclean
    popd
}

function build_rv_kernel()
{
    if [ $CHIP == 'qemu' ]; then
        local RV_KERNEL_CONFIG=defconfig
    else
        local RV_KERNEL_CONFIG=${VENDOR}_${CHIP}_${KERNEL_VARIANT}_defconfig
    fi
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
    make -j$(nproc) O=$RV_KERNEL_BUILD_DIR ARCH=riscv CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE Image dtbs modules
    err=$?
    popd

    if [ $err -ne 0 ]; then
		echo "making kernel modules failed"
		return $err
	fi

    mkdir -p $RV_OUTPUT_DIR
    cp $RV_KERNEL_BUILD_DIR/arch/riscv/boot/Image $RV_OUTPUT_DIR
    cp $RV_KERNEL_BUILD_DIR/vmlinux $RV_OUTPUT_DIR

    if [ $CHIP != 'qemu' ]; then
        cp $RV_KERNEL_BUILD_DIR/arch/riscv/boot/dts/sophgo/*.dtb $RV_OUTPUT_DIR
    fi
}

function clean_rv_kernel()
{
    rm -rf $RV_OUTPUT_DIR/Image
    rm -rf $RV_OUTPUT_DIR/vmlinux
    rm -rf $RV_OUTPUT_DIR/*.dtb

	rm -rf $RV_KERNEL_BUILD_DIR
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

    cp $RV_BUILDROOT_DIR/output/images/rootfs.cpio $RV_OUTPUT_DIR/initrd.img
    cp $RV_BUILDROOT_DIR/output/images/rootfs.tar $RV_OUTPUT_DIR/initrd.tar
}

function clean_rv_ramfs()
{
    rm -rf $RV_OUTPUT_DIR/initrd.*

    rm -rf $RV_BUILDROOT_DIR/output
}

function build_rv_pld()
{
    local PLD_MEMGEN=$SCRIPTS_DIR/mb2h/mb2h
    local PLD_OUT

    local RAMFS=$RV_OUTPUT_DIR/initrd.img
    local KERNEL=$RV_OUTPUT_DIR/Image
    local SBI=$RV_OUTPUT_DIR/fw_jump.bin
    local DTB=$RV_OUTPUT_DIR/mango.dtb

    if [ $# -lt 1 ]; then
        PLD_OUT=$PLD_INSTALL_DIR/out_$(date "+%Y%m%d_%H%M%S")
    else
        PLD_OUT=$1
    fi

    gcc -O2 ${PLD_MEMGEN}.c -o ${PLD_MEMGEN}

    if [ ! -f $KERNEL ]; then
        echo "$KERNEL not found"
        return
    fi

    if [ ! -f $DTB ]; then
        echo "$DTB not found"
        return
    fi

    if [ ! -f $RAMFS ]; then
        echo "$RAMFS not found"
        return
    fi

    if [ ! -f $SBI ]; then
        echo "$SBI not found"
        return
    fi

    mkdir -p $PLD_OUT

    echo 'generate riscv64 Image memory image'
    $PLD_MEMGEN $KERNEL $PLD_OUT/rv-kernel-%d.hex
    echo 'generate riscv64 dtb memory image'
    $PLD_MEMGEN $DTB $PLD_OUT/rv-dtb-%d.hex
    echo 'generate riscv64 ramfs memory image'
    $PLD_MEMGEN $RAMFS $PLD_OUT/rv-ramfs-%d.hex
    echo 'generate riscv64 opensbi memory image'
    $PLD_MEMGEN $SBI $PLD_OUT/rv-sbi-%d.hex
}

function clean_rv_pld()
{
    rm -rf $PLD_INSTALL_DIR
}

function clean_rv_all()
{
    clean_rv_sbi
    clean_rv_kernel
    clean_rv_ramfs
}

function build_rv_all()
{
    build_rv_sbi
    build_rv_kernel
    build_rv_ramfs
}

function run_rv_kernel()
{
    qemu-system-riscv64 -nographic -M virt \
        -kernel $RV_OUTPUT_DIR/Image \
        -initrd $RV_OUTPUT_DIR/initrd.img \
        -append "root=/dev/ram0 earlycon ignore_loglevel rootwait"
}

# global variables
CHIP=${CHIP:-mango}
KERNEL_VARIANT=${KERNEL_VARIANT:-normal} # normal, mininum, debug
VENDOR=${VENDOR:-sophgo}

# riscv specific variables
RISCV64_LINUX_CROSS_COMPILE=riscv64-linux-gnu-
RISCV64_ELF_CROSS_COMPILE=riscv64-unknown-elf-gnu-

# absolute path
RV_TOP_DIR=${TOP_DIR:-$(get_rv_top)}

RV_OUTPUT_DIR=$RV_TOP_DIR/install/soc_$CHIP/riscv64
PLD_INSTALL_DIR=${PLD_INSTALL_DIR:-$RV_OUTPUT_DIR/pld}

SCRIPTS_DIR=${SCRIPTS_DIR:-$RV_TOP_DIR/bootloader-arm64/scripts}
RV_SCRIPTS_DIR=$RV_TOP_DIR/bootloader-riscv/scripts

RV_KERNEL_SRC_DIR=$RV_TOP_DIR/linux-sophgo
RV_KERNEL_BUILD_DIR=$RV_KERNEL_SRC_DIR/build/$CHIP/$KERNEL_VARIANT

RV_BUILDROOT_DIR=$RV_TOP_DIR/bootloader-riscv/buildroot

RV_SBI_DIR=$RV_TOP_DIR/bootloader-riscv/opensbi-v0.8

