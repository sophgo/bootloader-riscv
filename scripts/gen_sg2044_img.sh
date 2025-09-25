#!/bin/bash

RV_UBUNTU_OFFICIAL_IMAGE=ubuntu-24.04.1-riscv64-sg2044-20241025.template.img
DOWNLOAD_RV_UBUNTU_OFFICIAL_IMAGE="wget https://github.com/sophgo/bootloader-riscv/releases/download/sg2044-v0.1/ubuntu-24.04.1-riscv64-sg2044-20241025.template.img.xz"
UNCOMPRESS_RV_UBUNTU_OFFICIAL_IMAGE="unxz $RV_UBUNTU_OFFICIAL_IMAGE.xz"

RV_EULER_OFFICIAL_IMAGE=openEuler-24.03-riscv64-sg2044-20241025.template.img
DOWNLOAD_RV_EULER_OFFICIAL_IMAGE="wget https://github.com/sophgo/bootloader-riscv/releases/download/sg2044-v0.1/openEuler-24.03-riscv64-sg2044-20241025.template.img.xz"
UNCOMPRESS_RV_EULER_OFFICIAL_IMAGE="unxz $RV_EULER_OFFICIAL_IMAGE.xz"

RV_SG2044_FSBL_BIN="https://github.com/sophgo/bootloader-riscv/releases/download/sg2044-v0.1/fsbl.bin"

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
dpkg -i /home/sophgo/bsp-debs/*.deb
echo '$nrconf{kernelhints} = 0;' > /etc/needrestart/conf.d/99_disable_kernel_hint.conf
apt autoremove -y || true
rm /etc/needrestart/conf.d/99_disable_kernel_hint.conf
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
rpm -i /home/sophgo/bsp-rpms/kernel-[0-9]*.riscv64.rpm
dracut --force --regenerate-all --no-hostonly
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

	if [ "$CHIP" = "sg2044" ]; then
		if [ ! -f "$RV_FIRMWARE_INSTALL_DIR/fsbl.bin" ]; then
			wget -O "$RV_FIRMWARE_INSTALL_DIR/fsbl.bin" "$RV_SG2044_FSBL_BIN"
		fi
	fi

	sudo cp -v $RV_FIRMWARE_INSTALL_DIR/fsbl.bin $EFI_PARTITION_DIR/riscv64

	if [ -f $RV_FIRMWARE_INSTALL_DIR/${CHIP^^}.fd ]; then
		sudo cp -v $RV_FIRMWARE_INSTALL_DIR/${CHIP^^}.fd $EFI_PARTITION_DIR/riscv64
	fi

	if [ -f $RV_FIRMWARE_INSTALL_DIR/u-boot.bin ]; then
		sudo cp -v $RV_FIRMWARE_INSTALL_DIR/u-boot.bin $EFI_PARTITION_DIR/riscv64
	fi

	sudo cp -v $RV_FIRMWARE_INSTALL_DIR/zsbl.bin $EFI_PARTITION_DIR/riscv64
	sudo cp -v $RV_FIRMWARE_INSTALL_DIR/fw_dynamic.bin $EFI_PARTITION_DIR/riscv64

	if [ "$CHIP" = "bm1690" ]; then
		sudo cp -v $RV_FIRMWARE_INSTALL_DIR/initrd.img $EFI_PARTITION_DIR/riscv64
		sudo cp -v $RV_FIRMWARE_INSTALL_DIR/rp_Image $EFI_PARTITION_DIR/riscv64
		sudo cp -v $RV_TOP_DIR/bootloader-riscv/scripts/bm1690-config.ini $RV_FIRMWARE_INSTALL_DIR/conf.ini
		sudo cp -v $RV_FIRMWARE_INSTALL_DIR/conf.ini $EFI_PARTITION_DIR/riscv64
	fi

	sudo cp -v $RV_FIRMWARE_INSTALL_DIR/${CHIP}-*.dtbo $EFI_PARTITION_DIR/riscv64

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

function build_rv_euler_kernel_native()
{
	local kernel_ver
	local rpm_build_dir="${HOME}/rpmbuild"

	pushd ${RV_TOP_DIR}

	rpmdev-setuptree
	find ${rpm_build_dir}/RPMS -type f -delete
	cp -f bootloader-riscv/packages/openeuler-24.03/kernel/kernel.spec      ${rpm_build_dir}/SPECS/
	cp -f bootloader-riscv/packages/openeuler-24.03/kernel/cpupower.config  ${rpm_build_dir}/SOURCES/
	cp -f bootloader-riscv/packages/openeuler-24.03/kernel/cpupower.service ${rpm_build_dir}/SOURCES/
	tar -czf ${rpm_build_dir}/SOURCES/kernel.tar.gz \
		--exclude-vcs \
		--transform s/linux-riscv/kernel/ \
		linux-riscv

	pushd linux-riscv
	IFS='.' read -ra kernel_ver <<< $(make kernelversion)
	sed -i \
		"/%global upstream_version/c\%global upstream_version ${kernel_ver[0]}.${kernel_ver[1]}" \
		${rpm_build_dir}/SPECS/kernel.spec
	sed -i \
		"/%global upstream_sublevel/c\%global upstream_sublevel ${kernel_ver[2]}" \
		${rpm_build_dir}/SPECS/kernel.spec
	popd

	pushd ${rpm_build_dir}
	rpmbuild -bb SPECS/kernel.spec

	mkdir -p ${RV_RPM_INSTALL_DIR}
	kernel_ver=${kernel_ver[0]}.${kernel_ver[1]}.${kernel_ver[2]}
	cp -f RPMS/riscv64/kernel-${kernel_ver}*.rpm ${RV_RPM_INSTALL_DIR}
	cp -f RPMS/riscv64/kernel-devel-${kernel_ver}*.rpm ${RV_RPM_INSTALL_DIR}
	cp -f RPMS/riscv64/perf-${kernel_ver}*.rpm ${RV_RPM_INSTALL_DIR}
	popd

	popd
}

# $1 repository dir
# $2 package name
# $3 version
# $4 code name
# $5 changelog file
function gen_changelog()
{
	local repo=$1
	local name=$2
	local version=$3
    local code=$4
	local file=$5

	echo "Generating change log $name ($version) [$repo]"

	pushd $repo


	local time=`git show --shortstat | grep -m1 '^Date' | sed -e 's/^Date: *//'`
	local _tm=`echo $time | sed -e 's/[+-][0-9][0-9][0-9][0-9]//'`
	local tm=`date -d "$_tm" +'%a, %d %b %Y %H:%M:%S'`
	local tz=`echo $time | grep -o '[+-][0-9][0-9][0-9][0-9]'`

	popd

	cat << EOF > $file
$name ($version) $code; urgency=medium

  * $name: $version

 -- SOPHGO <sales@sophgo.com>  $tm $tz
EOF
}

# $1 repository dir
# $2 exported source path
function prepare_ubuntu_kernel()
{
	local repo=$1
	local dest=$2

	# clean source repository before syncing
	pushd $repo
	make ARCH=riscv distclean
	make ARCH=riscv mrproper
	popd
	mkdir -p $dest
	rsync -ax --exclude .git $repo/* $dest
}

function clean_rv_ubuntu_kernel_native()
{
	local work_space=$RV_TOP_DIR/build/$CHIP/ubuntu
	local linux_riscv=$work_space/linux-riscv
	local linux_meta_riscv=$work_space/linux-meta-riscv
	local linux=$work_space/linux

	echo 'Remove legacy source code'
	rm -rf $linux_riscv $linux_meta_riscv $linux $work_space/*.log
	echo 'Cleanup deb files'
	rm -rf $work_space/*.deb
	rm -f $RV_DEB_INSTALL_DIR/*.deb
}

function export_rv_ubuntu_packages()
{
	local work_space=$RV_TOP_DIR/build/$CHIP/ubuntu

	mkdir -p $RV_DEB_INSTALL_DIR

	# image
	cp $work_space/linux-image-[0-9]*.deb $RV_DEB_INSTALL_DIR
	cp $work_space/linux-image-generic*.deb $RV_DEB_INSTALL_DIR

	# headers
	cp $work_space/linux-headers-[0-9]*.deb $RV_DEB_INSTALL_DIR
	cp $work_space/linux-riscv-headers*.deb $RV_DEB_INSTALL_DIR
	cp $work_space/linux-headers-generic*.deb $RV_DEB_INSTALL_DIR

	# modules
	cp $work_space/linux-modules*.deb $RV_DEB_INSTALL_DIR

    # generic
	cp $work_space/linux-generic*.deb $RV_DEB_INSTALL_DIR

	# tools  
	cp $work_space/linux-riscv-tools-*.deb $RV_DEB_INSTALL_DIR
	cp $work_space/linux-tools-[0-9]*.deb $RV_DEB_INSTALL_DIR
	cp $work_space/linux-tools-common*.deb $RV_DEB_INSTALL_DIR
	cp $work_space/linux-tools-generic*.deb $RV_DEB_INSTALL_DIR
}

function build_rv_ubuntu_kernel_native()
{
	local work_space=$RV_TOP_DIR/build/$CHIP/ubuntu
	local linux_riscv=$work_space/linux-riscv
	local linux_meta_riscv=$work_space/linux-meta-riscv
	local linux=$work_space/linux

	local distro_major=0
	local distro_minar=0
	local distro_patch=0

	clean_rv_ubuntu_kernel_native

	mkdir -p $work_space

	echo 'Prepare source code for linux-riscv package'
	prepare_ubuntu_kernel $RV_KERNEL_SRC_DIR $linux_riscv
	echo 'Prepare source code for linux package'
	prepare_ubuntu_kernel $RV_KERNEL_SRC_DIR $linux
	echo 'Prepare source code for linux-meta-riscv package'
	cp -r ${RV_TOP_DIR}/bootloader-riscv/packages/ubuntu-24.04/linux-meta-riscv $linux_meta_riscv

	pushd $RV_KERNEL_SRC_DIR
	local kernel_version=`make kernelversion`
	popd
	echo "Get kernel version $kernel_version"

	echo 'Setup debian build environment for linux-riscv package'
	cp -r ${RV_TOP_DIR}/bootloader-riscv/packages/ubuntu-24.04/linux-riscv/* $linux_riscv
	echo 'Generating changelog for linux-riscv package'
	gen_changelog $RV_KERNEL_SRC_DIR linux-riscv "$kernel_version-$distro_major.$distro_minar.$distro_patch" noble \
		$linux_riscv/debian/changelog
	gen_changelog $RV_KERNEL_SRC_DIR linux-riscv "$kernel_version-$distro_major.$distro_minar.$distro_patch" noble \
		$linux_riscv/debian.riscv/changelog
	gen_changelog $RV_KERNEL_SRC_DIR linux-riscv "$kernel_version-$distro_major.$distro_minar" noble \
		$linux_riscv/debian.master/changelog
	# change version information in debian/control
	sed -e "s/\${KERNEL_VERSION}/$kernel_version/g" -i $linux_riscv/debian/control
	sed -e "s/\${DISTRO_MAJOR}/$distro_major/g" -i $linux_riscv/debian/control


	echo 'Setup debian build environment for linux package'
	cp -r ${RV_TOP_DIR}/bootloader-riscv/packages/ubuntu-24.04/linux/* $linux
	echo 'Generating changelog for linux package'
	gen_changelog $RV_KERNEL_SRC_DIR linux "$kernel_version-$distro_major.$distro_minar" noble $linux/debian/changelog
	gen_changelog $RV_KERNEL_SRC_DIR linux "$kernel_version-$distro_major.$distro_minar" noble $linux/debian.master/changelog
	# change version information in debian/control
	sed -e "s/\${KERNEL_VERSION}/$kernel_version/g" -i $linux/debian/control
	sed -e "s/\${DISTRO_MAJOR}/$distro_major/g" -i $linux/debian/control

	echo 'Generating changelog for linux-meta-riscv package'
	gen_changelog $RV_KERNEL_SRC_DIR linux-meta-riscv "$kernel_version-$distro_major.$distro_minar.$distro_patch" noble \
		$linux_meta_riscv/debian/changelog
	# change version information in debian/control
	sed -e "s/\${KERNEL_VERSION}/$kernel_version/g" -i $linux_meta_riscv/debian/control
	sed -e "s/\${DISTRO_MAJOR}/$distro_major/g" -i $linux_meta_riscv/debian/control

	echo 'Build linux-riscv package'
	pushd $linux_riscv
	fakeroot debian/rules binary do_skip_checks=true do_lib_rust=false 2>&1 | tee ../compile-linux-riscv.log
	popd

	echo 'Build linux package'
	pushd $linux
	fakeroot debian/rules binary 2>&1 | tee ../compile-linux.log
	popd

	echo 'Build linux-riscv-meta package'
	pushd $linux_meta_riscv
	fakeroot debian/rules binary 2>&1 | tee ../compile-linux-meta-riscv.log
	popd

	export_rv_ubuntu_packages
}

function clean_rv_debian_kernel_native()
{
	local work_space=$RV_TOP_DIR/build/$CHIP/debian

    if [[ ! -d $work_space ]]; then
        return
    fi

	echo 'Remove legacy source code'
    pushd $work_space
	rm -rf linux* *.log
	echo 'Cleanup deb files'
	rm -rf $work_space/*.deb
	rm -f $RV_DEBIAN_DEB_INSTALL_DIR/*.deb
    popd
}

# $1 repository dir
# $2 exported source path
function prepare_debian_kernel()
{
	local repo=$1
	local dest=$2

	# clean source repository before syncing
	pushd $repo
	make ARCH=riscv distclean
	make ARCH=riscv mrproper
	popd

    rm -rf $dest

    cp -r $repo $dest
}

function export_rv_debian_packages()
{
	local work_space=$RV_TOP_DIR/build/$CHIP/debian

	mkdir -p $RV_DEBIAN_DEB_INSTALL_DIR

	cp $work_space/*.deb $RV_DEBIAN_DEB_INSTALL_DIR
	cp $work_space/*.udeb $RV_DEBIAN_DEB_INSTALL_DIR
}

# $1: kernel source dir
function patch_debian_kernel()
{
    pushd $1
    git apply debian/patches/debian/perf-traceevent-support-asciidoctor-for-documentatio.patch
    git apply debian/patches/debian/documentation-drop-sphinx-version-check.patch
    git apply debian/patches/bugfix/all/revert-tools-build-clean-cflags-and-ldflags-for-fixdep.patch
    git apply debian/patches/debian/fixdep-allow-overriding-hostcc-and-hostld.patch
    git apply debian/patches/debian/gitignore.patch
    git apply debian/patches/debian/kbuild-abort-build-if-subdirs-used.patch
    git apply debian/patches/debian/kbuild-look-for-module.lds-under-arch-directory-too.patch
    git apply debian/patches/debian/kernelvariables.patch
    git apply debian/patches/debian/linux-perf-remove-remaining-source-filenames-from-executable.patch
    git apply debian/patches/debian/makefile-make-compiler-version-comparison-optional.patch
    git apply debian/patches/debian/tools-perf-install-python-bindings.patch
    git apply debian/patches/debian/tools-perf-perf-read-vdso-in-libexec.patch
    git apply debian/patches/debian/uname-version-timestamp.patch
    git apply debian/patches/debian/version.patch
    popd
}

function build_rv_debian_kernel_native()
{
	local work_space=$RV_TOP_DIR/build/$CHIP/debian

	local distro_major=1

	clean_rv_debian_kernel_native

	pushd $RV_KERNEL_SRC_DIR
	local kernel_version=`make kernelversion`
	popd
	echo "Get kernel version $kernel_version"

	local linux=$work_space/linux-$kernel_version

	mkdir -p $work_space

	echo 'Prepare source code for linux package'
	prepare_debian_kernel $RV_KERNEL_SRC_DIR $linux

	echo 'Setup debian build environment for linux package'
	cp -r ${RV_TOP_DIR}/bootloader-riscv/packages/debian-13/linux/. $linux

	echo 'Generating changelog for linux package'
	gen_changelog $RV_KERNEL_SRC_DIR linux-$kernel_version "$kernel_version-$distro_major" trixie $linux/debian/changelog

    echo 'Applying debian kernel patches'
    patch_debian_kernel $linux

	echo 'Build linux package'
	pushd $linux
    export DEB_BUILD_OPTIONS="parallel=$(nproc)"
    fakeroot debian/rules debian/control-real
	fakeroot debian/rules binary 2>&1 | tee ../compile-linux.log
	popd

	export_rv_debian_packages
}
