# How to Build Linux Kernel Related rpm Packages of openEuler 24.03

All commands should execute on RISC-V based machines, and maybe openEuler distribution is required.
This can't work on x86 machines.

## Prepare Kernel Source
Rename the directory of linux kernel source to 'kernel'
```
mv linux-riscv kernel
```
Enter your kernel source tree, and make it clean
```
cd kernel
make distclean
make mrproper
```
And maybe there is 'build' directory in your source code, if you ever build your source code before.
```
rm -rf build
```
Create a tar ball of this kernel. Don't include git informations.
```
cd ../
tar --exclude=.git -czvf kernel.tar.gz kernel
```

## Prepare RPM Build Environment
Install tools.
```
sudo yum install -y rpmdevtools
```
Install dependencies
```
sudo yum-builddep kernel.spec
```
Create rpm build tree
```
rpmdev-setuptree
```
After execute this command, a directory named rpmbuild will be created at your home directory.
Don't use root privilidge for this command.

Copy kernel tar ball to ~/rpmbuild/SOURCES
```
cp kernel.tar.gz ~/rpmbuild/SOURCES/
```
Copy spec file to ~/rpmbuild/SPECS. Enter bootloader-riscv/packages/openeuler-24.03/kernel
```
cd bootloader-riscv/packages/openeuler-24.03/kernel
```
```
cp kernel.spec ~/rpmbuild/SPECS/
```
Copy other source files
```
cp cpupower.config cpupower.service ~/rpmbuild/SOURCES/
```
Modify kernel.spec as the need of your kernel.
```
Modify variable:

%global upstream_version    6.12    /* MUST be the same with your kernel */
%global upstream_sublevel   8       /* MUST be the same with your kernel */
%global devel_release       0
%global maintenance_release .0.0     
%global pkg_release         .0
```
upstream\_version and upstream\_sublevel MUST match the version of your kernel.
You can execute below command to see your kernel version.
Enter your kernel source tree
```
cd kernel
make kernelversion
```
## Start Building
Enter ~/rpmbuild directory
```
cd ~/rpmbuild
rpmbuild -bb SPECS/kernel.spec
```
root privilidge is not needed and it is not encouraged using sudo anywhere.

## Find RPMs
You can find RPMs in ~/rpmbuild/RPMS
