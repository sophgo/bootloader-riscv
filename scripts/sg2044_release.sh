#!/bin/bash

USER=
PASSWORD=
SERVER=172.28.141.89
TARGET_DIR=

ISO_SERVER=172.26.167.181
ISO_DIR=/public/SG2044/ISO

PLATFORMS='SD3-10 SD3-10-LB SD3-12 SRA3-40 SRA3-40-LB SRA3-40-8 SRM31'

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

function download()
{
    if [ $# != 2 ]; then
        echo "Invalid use of '$FUNCNAME'"
        return 1
    fi

    local TARGET=$TARGET_DIR/$1

    echo "Downloading $TARGET -> $2"

    lftp -u $USER,$PASSWORD ftp://$SERVER -e "get $TARGET_DIR/$1 -o $2; quit" > /dev/null
}

function release_bios()
{
    local LOCAL_BIOS_DIR=$TMP/BIOS

    if [ -d $LOCAL_BIOS_DIR ]; then
        echo "$LOCAL_BIOS_DIR already exists"
        return 1
    fi

    mkdir -p $LOCAL_BIOS_DIR

    for PLAT in $PLATFORMS; do
        local LOCAL_BIOS_PLAT_DIR=$LOCAL_BIOS_DIR/$PLAT
        mkdir -p $LOCAL_BIOS_PLAT_DIR
        download $PLAT/firmware/firmware.bin $LOCAL_BIOS_PLAT_DIR/firmware.bin
        download $PLAT/firmware/firmware.img $LOCAL_BIOS_PLAT_DIR/firmware.img
        download $PLAT/firmware/obmc-bios.tar.gz $LOCAL_BIOS_PLAT_DIR/obmc-bios.tar.gz
    done

    download $PLAT/firmware/sg2044_firmware_release_note.md $LOCAL_BIOS_DIR

    # generate ReadMe.txt
    cat > $LOCAL_BIOS_DIR/ReadMe.md << 'EOF'
# firmware.bin

BIOS image, it can be used by BIOS and BMC when updating.


# firmware.img

SD card BIOS image, it is used to create a bootable SD card.
You can use dd command to generate a bootable SD card.

On a linux PC:

sudo dd if=firmware.img of=/dev/sda bs=512 status=progress oflag=direct

Where /dev/sda is the device file of your SD card.

Note that, all data will lost, please backup your data in SD card if necessary.
EOF

    # compress BIOS
    mkdir -p $OUTPUT
    pushd $LOCAL_BIOS_DIR/..
    zip -r $OUTPUT/BIOS.zip BIOS
    popd
}

function download_dir()
{
    if [ $# != 2 ]; then
        echo "Invalid use of '$FUNCNAME'"
        return 1
    fi

    local TARGET=$TARGET_DIR/$1

    echo "Downloading $TARGET -> $2"

    lftp -u $USER,$PASSWORD ftp://$SERVER -e "mirror $TARGET_DIR/$1 $2; quit"
}

function release_kernel()
{
    download_dir SD3-10/package $TMP

    mv $TMP/debian $TMP/linux-deb-debian
    mv $TMP/ubuntu $TMP/linux-deb-ubuntu
    mv $TMP/euler $TMP/linux-rpm-openeuler

    mkdir -p $OUTPUT
    pushd $TMP
    echo 'Compress debian kernel'
    zip -r $OUTPUT/linux-deb-debian.zip linux-deb-debian
    echo 'Compress ubuntu kernel'
    zip -r $OUTPUT/linux-deb-ubuntu.zip linux-deb-ubuntu
    echo 'Compress openEuler kernel'
    zip -r $OUTPUT/linux-rpm-openeuler.zip linux-rpm-openeuler
    popd
}

function release_image()
{
    download_dir SD3-10/image $TMP

    echo 'Uncompress openEuler image'
    unxz -T0 -c $TMP/openEuler-24.03-riscv64-sg2044-*.img.xz > $TMP/openEuler-24.03-riscv64-sg2044.img
    echo 'Uncompress ubuntu image'
    unxz -T0 -c $TMP/ubuntu-24.04.1-riscv64-sg2044-*.img.xz > $TMP/ubuntu-24.04.1-riscv64-sg2044.img

    mkdir -p $OUTPUT

    echo 'Recompress openEuler image'
    zip $OUTPUT/openEuler-24.03-riscv64-sg2044.img.zip $TMP/openEuler-24.03-riscv64-sg2044.img
    echo 'Recompress ubuntu image'
    zip $OUTPUT/ubuntu-24.04.1-riscv64-sg2044.img.zip $TMP/ubuntu-24.04.1-riscv64-sg2044.img
}

function release_iso()
{ 
    mkdir -p $OUTPUT

    pushd $OUTPUT
    wget http://${ISO_SERVER}${ISO_DIR}/debian-13.3.0-riscv64-netinst-sophgo.iso.zip
    popd
}

function get_release_note()
{
    mkdir -p $OUTPUT
    download SD3-10/sg2044_release_note.md $OUTPUT/sg2044_release_note.md
}

function calc_md5sum()
{
    pushd $OUTPUT
    md5sum * > $TMP/md5sum.txt
    popd
    mv $TMP/md5sum.txt $OUTPUT
}

# get FTP user name and password
read -p 'DailyBuild server account: ' USER
read -p 'DailyBuild server password: ' -s PASSWORD; echo
read -p 'DailyBuild directory: ' DIR

TARGET_DIR=/sg2260/image/SG2044/daily_build/$DIR

WORKSPACE=$(get_rv_top)/release

TMP=$WORKSPACE/tmp
OUTPUT=$WORKSPACE/$(date +%Y%m%d)

if [ -e $WORKSPACE ]; then
    echo "Error, '$WORKSPACE' already exists, remove it first"
    exit 1
fi

release_bios
release_kernel
release_image
release_iso
get_release_note
calc_md5sum

