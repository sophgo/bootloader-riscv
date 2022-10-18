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


function build_rv_ltp()
{
    pushd $RV_LTP_SRC_DIR
    if [ ! -f "configure" ]; then
        make autotools
    fi

    ./configure --prefix=$RV_LTP_OUTPUT_DIR --host=riscv64-linux-gnu  --without-tirpc
    make -j$(nproc) ARCH=riscv CROSS_COMPILE=${RISCV64_LINUX_CROSS_COMPILE}gcc
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
    make -j$(nproc) O=$RV_KERNEL_BUILD_DIR ARCH=riscv CROSS_COMPILE=$RISCV64_LINUX_CROSS_COMPILE Image dtbs modules
    err=$?
    popd

    if [ $err -ne 0 ]; then
		echo "making kernel modules failed"
		return $err
	fi

    mkdir -p $RV_OUTPUT_DIR
    cp $RV_KERNEL_BUILD_DIR/arch/riscv/boot/Image $RV_OUTPUT_DIR/riscv64_Image
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
    build_rv_uroot
}

function run_rv_ramfs()
{
    qemu-system-riscv64 -nographic -M virt \
        -bios /usr/lib/riscv64-linux-gnu/opensbi/generic/fw_jump.elf \
        -kernel $RV_OUTPUT_DIR/Image \
        -initrd $RV_OUTPUT_DIR/initrd.img \
        -append "root=/dev/ram0 earlycon ignore_loglevel rootwait"
}

function build_rv_uroot()
{
    pushd $RV_UROOT_DIR
    GOARCH=riscv64 go build
    GOOS=linux GOARCH=riscv64 $RV_UROOT_DIR/u-root -uroot-source $RV_UROOT_DIR -build bb \
        -o $RV_UROOT_DIR/initramfs.cpio core boot
    popd
    cp $RV_UROOT_DIR/initramfs.cpio $RV_OUTPUT_DIR/uroot.cpio
}

function run_rv_uroot()
{
    qemu-system-riscv64 -nographic -M virt \
        -bios /usr/lib/riscv64-linux-gnu/opensbi/generic/fw_jump.elf \
        -kernel $RV_OUTPUT_DIR/Image \
        -initrd $RV_OUTPUT_DIR/uroot.cpio \
        -append "root=/dev/ram0 earlycon ignore_loglevel rootwait"
}

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

function build_rv_zsbl()
{
    local err

    pushd $RV_ZSBL_DIR
    make CROSS_COMPILE=$RISCV64_ELF_CROSS_COMPILE O=$RV_ZSBL_BUILD_DIR ARCH=riscv sg2042_defconfig
    err=$?
    popd

    if [ $err -ne 0 ]; then
		echo "making zsbl config failed"
		return $err
	fi

    pushd $RV_ZSBL_BUILD_DIR
    make -j$(nproc) CROSS_COMPILE=$RISCV64_ELF_CROSS_COMPILE ARCH=riscv
    err=$?
    popd

    if [ $err -ne 0 ]; then
		echo "making zsbl failed"
		return $err
	fi

    mkdir -p $RV_OUTPUT_DIR

    cp $RV_ZSBL_BUILD_DIR/zsbl.bin $RV_OUTPUT_DIR
}

function clean_rv_zsbl()
{

    rm -rf $RV_OUTPUT_DIR/zsbl.bin
    rm -rf $RV_ZSBL_BUILD_DIR
}

function run_rv_zsbl()
{
    qemu-system-riscv64 -nographic -M virt -bios $RV_OUTPUT_DIR/zsbl.bin
}

# global variables
CHIP=${CHIP:-mango}
KERNEL_VARIANT=${KERNEL_VARIANT:-normal} # normal, mininum, debug
VENDOR=${VENDOR:-sophgo}

# absolute path
RV_TOP_DIR=${TOP_DIR:-$(get_rv_top)}

RV_OUTPUT_DIR=$RV_TOP_DIR/install/soc_$CHIP/riscv64
PLD_INSTALL_DIR=${PLD_INSTALL_DIR:-$RV_OUTPUT_DIR/pld}

SCRIPTS_DIR=${SCRIPTS_DIR:-$RV_TOP_DIR/bootloader-arm64/scripts}
RV_SCRIPTS_DIR=$RV_TOP_DIR/bootloader-riscv/scripts

RV_LTP_SRC_DIR=$RV_TOP_DIR/bsp-solutions/ltp
RV_LTP_OUTPUT_DIR=$RV_OUTPUT_DIR/ltp


RV_KERNEL_SRC_DIR=$RV_TOP_DIR/linux-sophgo
RV_KERNEL_BUILD_DIR=$RV_KERNEL_SRC_DIR/build/$CHIP/$KERNEL_VARIANT

RV_BUILDROOT_DIR=$RV_TOP_DIR/bootloader-riscv/buildroot
RV_ZSBL_DIR=$RV_TOP_DIR/bootloader-riscv/zsbl
RV_SBI_DIR=$RV_TOP_DIR/bootloader-riscv/opensbi-v0.8
RV_UROOT_DIR=$RV_TOP_DIR/bootloader-riscv/u-root

RV_ZSBL_BUILD_DIR=$RV_ZSBL_DIR/build/$CHIP/$KERNEL_VARIANT

RV_GCC_DIR=$RV_TOP_DIR/gcc-riscv
RV_ELF_GCC_INSTALL_DIR=$RV_GCC_DIR/gcc-riscv64-unknown-elf
RV_LINUX_GCC_INSTALL_DIR=$RV_GCC_DIR/gcc-riscv64-unknown-linux-gnu

# riscv specific variables
RISCV64_LINUX_CROSS_COMPILE=$RV_LINUX_GCC_INSTALL_DIR/bin/riscv64-unknown-linux-gnu-
RISCV64_ELF_CROSS_COMPILE=$RV_ELF_GCC_INSTALL_DIR/bin/riscv64-unknown-elf-
