# 1.1.0_2024-12-25

## [zsbl(master)](https://github.com/sophgo/zsbl/tree/master)

+ SG2044: Fix footer &quot;[eof]&quot; not found in EDK II phase (@Jingyu Li in [a3b608caf8edb15](https://github.com/sophgo/zsbl/commit/a3b608caf8edb15) at 2024-12-19 22:53:19)

  > Set the NULL character after the footer rather than before.
  > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;
  >
+ SG2044: Remove debug information of mtd device (@Chao Wei in [d47989c20cc9fc6](https://github.com/sophgo/zsbl/commit/d47989c20cc9fc6) at 2024-12-17 08:36:41)
+ SG2042: Support parseing MAC from conf.ini (@Chao Wei in [1864a4ade785fd9](https://github.com/sophgo/zsbl/commit/1864a4ade785fd9) at 2024-12-13 15:27:08)
+ SG2044: Support parseing MAC from conf.ini (@Chao Wei in [46fdc55a77ba9e1](https://github.com/sophgo/zsbl/commit/46fdc55a77ba9e1) at 2024-12-13 15:20:55)
+ Add lib to support ethernet MAC operations (@Chao Wei in [c20883b669d7d71](https://github.com/sophgo/zsbl/commit/c20883b669d7d71) at 2024-12-13 15:20:06)
+ SG2044: Support SPI NOR flash boot (@Chao Wei in [1d7b025be539b1a](https://github.com/sophgo/zsbl/commit/1d7b025be539b1a) at 2024-12-13 13:28:07)

  > 1. Add SOPHGO SPIFMC driver
  > 2. Change flash file table from 0x60_0000 to 0x8000
  >
+ SG2044: Load config file to a conventional address (@Chao Wei in [a7a46291660399b](https://github.com/sophgo/zsbl/commit/a7a46291660399b) at 2024-12-12 13:56:59)

  > Instead of loading conf.ini to an allocated address,
  > load conf.ini to a conventional address, aka 0x89000000.
  > EDK2 will get conf.ini from there and getting informations about
  > SoC and boards.
  >
+ Modify l2 cache size to 2MiB in sg2044 evb conf.ini (@lin fei in [f4aa049e9883272](https://github.com/sophgo/zsbl/commit/f4aa049e9883272) at 2024-12-05 08:58:26)

  > Signed-off-by: lin fei &lt;peng.lin@sophgo.com&gt;
  >
+ Add sg2044 evb conf.ini in zsbl Repository (@lin fei in [22fd2846a4b1d4e](https://github.com/sophgo/zsbl/commit/22fd2846a4b1d4e) at 2024-12-04 07:24:05)

  > Signed-off-by: lin peng &lt;peng.lin@sophgo.com&gt;
  >
+ qemu riscv64 virt works (@Chao Wei in [7fb853c748aedbc](https://github.com/sophgo/zsbl/commit/7fb853c748aedbc) at 2024-11-27 12:56:46)
+ Remove unused ARM code (@Chao Wei in [a2b7d8d84bf9635](https://github.com/sophgo/zsbl/commit/a2b7d8d84bf9635) at 2024-11-27 12:23:39)
+ Add serial device driver model (@Chao Wei in [c5842115d6de303](https://github.com/sophgo/zsbl/commit/c5842115d6de303) at 2024-11-27 11:56:38)
+ SG2042: Fixbug, wrong dtb used (@Chao Wei in [14568dc124fa9a3](https://github.com/sophgo/zsbl/commit/14568dc124fa9a3) at 2024-11-26 12:11:37)

  > 1. Setup dtb names after config init
  > 2. Add prefix &quot;riscv64&quot; in sgfat lib
  > 3. Setup boot device priority before loading any files
  >
+ Enable stack protection (@Chao Wei in [ec9b9f5fa57f17c](https://github.com/sophgo/zsbl/commit/ec9b9f5fa57f17c) at 2024-11-22 02:48:54)
+ Remove unused config file (@Chao Wei in [32eb1b0e3410345](https://github.com/sophgo/zsbl/commit/32eb1b0e3410345) at 2024-11-22 02:13:44)

  > remove sg2042_pld_defconfig and sg2044_pld_defconfig
  >
+ REFACTOR: sgcfg and sgmtd works (@Chao Wei in [ab67ec56697228a](https://github.com/sophgo/zsbl/commit/ab67ec56697228a) at 2024-11-21 14:48:05)
+ REFACTOR: Intigrite SPI flash controller to mtd (@Chao Wei in [0813ea2e5481e2a](https://github.com/sophgo/zsbl/commit/0813ea2e5481e2a) at 2024-11-21 09:02:32)
+ REFACTOR: SG2042 SD boot works (@Chao Wei in [63bae6d218693af](https://github.com/sophgo/zsbl/commit/63bae6d218693af) at 2024-11-21 07:53:06)
+ REFACTOR: SG2042 base (@Chao Wei in [691121ce146c9d9](https://github.com/sophgo/zsbl/commit/691121ce146c9d9) at 2024-11-20 07:18:26)
+ REFACTOR: Merge final (@Chao Wei in [bb85cdc4609caa4](https://github.com/sophgo/zsbl/commit/bb85cdc4609caa4) at 2024-11-20 07:03:04)
+ REFACTOR: BM1690 TPU scalar works (@Chao Wei in [55c7920f5b69c3a](https://github.com/sophgo/zsbl/commit/55c7920f5b69c3a) at 2024-11-20 06:54:03)
+ REFACTOR: BM1690 TPU scalar initial commit (@Chao Wei in [ff6610a873a29c5](https://github.com/sophgo/zsbl/commit/ff6610a873a29c5) at 2024-11-20 06:50:00)

  > Forked from SG2044
  >
+ REFACTOR: Support PCIe and SoC boot (@Chao Wei in [df34642605919f4](https://github.com/sophgo/zsbl/commit/df34642605919f4) at 2024-11-20 06:48:45)
+ REFACTOR: SG2044 CPU mode only (@Chao Wei in [5e583fe1325837f](https://github.com/sophgo/zsbl/commit/5e583fe1325837f) at 2024-11-20 06:48:24)
+ Fixbug: %ld and %lld print out &#x27;d&#x27; after digital (@Chao Wei in [b46cf1741b5d3b8](https://github.com/sophgo/zsbl/commit/b46cf1741b5d3b8) at 2024-11-20 06:47:41)
+ REFACTOR: SG2044 new framework demo (@Chao Wei in [0906a4ad9eae7c7](https://github.com/sophgo/zsbl/commit/0906a4ad9eae7c7) at 2024-11-20 06:47:01)
+ REFACTOR: remove legacy IO layer (@Chao Wei in [8ee85d0c95a862b](https://github.com/sophgo/zsbl/commit/8ee85d0c95a862b) at 2024-11-20 06:45:40)
+ REFACTOR: Append riscv64 directory for fat load (@Chao Wei in [59c57fe923314fe](https://github.com/sophgo/zsbl/commit/59c57fe923314fe) at 2024-11-20 06:45:33)
+ REFACTOR: bootdev works (@Chao Wei in [4fffc14fcc32cf8](https://github.com/sophgo/zsbl/commit/4fffc14fcc32cf8) at 2024-11-20 06:45:26)
+ REFACTOR: Add new fat32 testcase (@Chao Wei in [9fd1f2204442237](https://github.com/sophgo/zsbl/commit/9fd1f2204442237) at 2024-11-20 06:45:20)

  > new case uses block devices
  >
+ REFACTOR: Add pr_line for easier debug (@Chao Wei in [fbd2f8a9acc6e42](https://github.com/sophgo/zsbl/commit/fbd2f8a9acc6e42) at 2024-11-20 06:45:12)
+ REFACTOR: Remove open/close of block device (@Chao Wei in [02d6bb487548741](https://github.com/sophgo/zsbl/commit/02d6bb487548741) at 2024-11-20 06:45:00)
+ RISC-V: Fixbug exception vector may not 4 aligned (@Chao Wei in [f96f6a19bf2fe2b](https://github.com/sophgo/zsbl/commit/f96f6a19bf2fe2b) at 2024-11-20 06:44:53)
+ REFACTOR: Add diskio porting layer for fatfs (@Chao Wei in [8659f9e71d5eca3](https://github.com/sophgo/zsbl/commit/8659f9e71d5eca3) at 2024-11-20 06:44:44)
+ REFACTOR: Remove old SD driver (@Chao Wei in [9be519f2eb26587](https://github.com/sophgo/zsbl/commit/9be519f2eb26587) at 2024-11-20 06:44:31)
+ REFACTOR: SD works (@Chao Wei in [fa595e437dadd32](https://github.com/sophgo/zsbl/commit/fa595e437dadd32) at 2024-11-20 06:44:06)
+ REFACTOR: SG2044 refactor base (@Chao Wei in [e6c8c32bfe1806e](https://github.com/sophgo/zsbl/commit/e6c8c32bfe1806e) at 2024-11-20 06:42:56)
+ REFACTOR: add subsys_init and subsys_probe (@Chao Wei in [f77b9e3ad4ee180](https://github.com/sophgo/zsbl/commit/f77b9e3ad4ee180) at 2024-11-20 06:40:06)
+ REFACTOR: Call plat_main in function main (@Chao Wei in [5eda312c95a6667](https://github.com/sophgo/zsbl/commit/5eda312c95a6667) at 2024-11-20 06:39:29)

  > boot sequence of zsbl
  >
  > 1. plat_early_setup: very early, normally setup CPU core control
  >    registers. It is called before any other instructions.
  > 2. setup stack pointer
  > 3. clear bss
  > 4. load data
  > 5. generic timer init
  > 6. early init, marked as early_init macro, normally, uart init
  > 7. arch init, marked as arch_init
  > 8. platform init, marked as plat_init
  > 9. module init, normally driver init
  > 10. main function
  > 11. call plat_main from function main
  > 12. if test mode enabled, main function run test cases instead of
  >     normal boot flow
  >
+ REFACTOR: Enable device model (@Chao Wei in [7d29514d8088c90](https://github.com/sophgo/zsbl/commit/7d29514d8088c90) at 2024-11-20 06:39:15)
+ REFACTOR: refactor test mode (@Chao Wei in [aad4dc0b4c3ceb8](https://github.com/sophgo/zsbl/commit/aad4dc0b4c3ceb8) at 2024-11-20 06:39:06)

  > 1. remove firmware_start
  > 2. make default main function as weak, if test mode selected,
  >    main in test.c will overwrite the default one in main.c
  >
+ REFACTOR: Remove unused output files (@Chao Wei in [defa6ad3bd13c85](https://github.com/sophgo/zsbl/commit/defa6ad3bd13c85) at 2024-11-20 06:38:52)
+ REFACTOR: Support SOPHGO MTD boot device framework (@Chao Wei in [b10dbce6f65557d](https://github.com/sophgo/zsbl/commit/b10dbce6f65557d) at 2024-11-20 06:38:44)
+ REFACTOR: Add flash config framework (@Chao Wei in [84b5d34e622ccea](https://github.com/sophgo/zsbl/commit/84b5d34e622ccea) at 2024-11-20 06:38:37)
+ REFACTOR: Add SOPHGO fat boot device framework (@Chao Wei in [777db123785b5e9](https://github.com/sophgo/zsbl/commit/777db123785b5e9) at 2024-11-20 06:38:28)
+ REFACTOR: Fix name of main menu (@Chao Wei in [4d3c702f9275a9f](https://github.com/sophgo/zsbl/commit/4d3c702f9275a9f) at 2024-11-20 06:38:12)
+ REFACTOR: Support boot device driver model (@Chao Wei in [f7909bc1a8e23fc](https://github.com/sophgo/zsbl/commit/f7909bc1a8e23fc) at 2024-11-20 06:38:03)
+ REFACTOR: Add MTD device driver model (@Chao Wei in [4581ffe712ed581](https://github.com/sophgo/zsbl/commit/4581ffe712ed581) at 2024-11-20 06:37:53)
+ REFACTOR: Support block device driver model (@Chao Wei in [a38ff57b06c5535](https://github.com/sophgo/zsbl/commit/a38ff57b06c5535) at 2024-11-20 06:37:33)
+ REFACTOR: Add platform device model (@Chao Wei in [68bc32f521afae4](https://github.com/sophgo/zsbl/commit/68bc32f521afae4) at 2024-11-20 06:37:23)
+ REFACTOR: Support builtin dtb (@Chao Wei in [d5a7eaff64f5016](https://github.com/sophgo/zsbl/commit/d5a7eaff64f5016) at 2024-11-20 06:37:05)
+ REFACTOR: Add device model base code (@Chao Wei in [f0c5bdfbd361127](https://github.com/sophgo/zsbl/commit/f0c5bdfbd361127) at 2024-11-20 06:33:25)

## [linux-riscv(sg2042-rel-6.1.31)](https://github.com/sophgo/linux-riscv/tree/sg2042-rel-6.1.31)

+ sophgo_mango_normal_defconfig : (@zhaohui-yan in [57da181c901f4a5](https://github.com/sophgo/linux-riscv/commit/57da181c901f4a5) at 2024-12-24 08:17:44)

  > 1. Add ipmi and raid card drivers
  > 2. Disable CONFIG_COMPAT_BRK
  >
+ riscv:dts: Add cache info for SG2042 (@Xiaoguang Xing in [6f7f292daf8e32c](https://github.com/sophgo/linux-riscv/commit/6f7f292daf8e32c) at 2024-12-02 22:03:44)

  > Signed-off-by: Xiaoguang Xing &lt;xiaoguang.xing@sophgo.com&gt;
  >
+ drivers:pci: SC11 support msi-x (@fengchun.li in [70b864591032340](https://github.com/sophgo/linux-riscv/commit/70b864591032340) at 2024-11-16 01:02:10)

  > drivers:pci: SC11 support msi-x
  > Signed-off-by: fengchun.li &lt;fengchun.li@sophgo.com&gt;
  >
+ driver: spifmc: fix spif bug when bs of dd exceed 64k (@zhencheng.zhang in [44a16cafb4626ca](https://github.com/sophgo/linux-riscv/commit/44a16cafb4626ca) at 2024-10-30 05:28:12)

  > - data read is divided into 64k due to IP restrictions that
  >   reg TRANS_NUM is 16bit
  >   Signed-off-by: zhencheng.zhang &lt;zhencheng.zhang@sophgo.com&gt;
  >

## [bootloader-riscv(master)](https://github.com/sophgo/bootloader-riscv/tree/master)

+ Add pxe boot. (@zhaohui-yan in [93245269b0655de](https://github.com/sophgo/bootloader-riscv/commit/93245269b0655de) at 2024-12-24 04:12:01)
+ script:sg2042:: avoid repeated umount (@sharim in [9ea83bac2605cb0](https://github.com/sophgo/bootloader-riscv/commit/9ea83bac2605cb0) at 2024-12-20 02:47:32)

  > Signed-off-by: sharim &lt;sharim.pyi@gmail.com&gt;
  >
+ script:sg2042::fix fedora image&#x27;s rootfs path (@sharim in [68a3a36bdf83bda](https://github.com/sophgo/bootloader-riscv/commit/68a3a36bdf83bda) at 2024-12-19 03:17:49)

  > Signed-off-by: sharim &lt;sharim.pyi@gmail.com&gt;
  >
+ script:sg2042::modify behavior of &#x60;mkdir&#x60; and &#x60;umount&#x60; (@sharim in [350798ff66abb4b](https://github.com/sophgo/bootloader-riscv/commit/350798ff66abb4b) at 2024-12-18 12:36:15)

  > 1. add &#x27;-p&#x27; to &#x60;mkdir&#x60; to avoid &quot;create existed directory&quot; error
  > 2. add &#x27;-R&#x27; to &#x60;umount&#x60; to auto umount rootfs recursively
  >    Signed-off-by: sharim &lt;sharim.pyi@gmail.com&gt;
  >
+ scripts: fix some bugs (@JianHang Wu in [191c4efbe36733e](https://github.com/sophgo/bootloader-riscv/commit/191c4efbe36733e) at 2024-12-13 10:19:02)

  > Signed-off-by: JianHang Wu &lt;jianhang.wu@sophgo.com&gt;
  >
+ Scripts:change the default offset and fix a bug (@JianHang Wu in [95c8a85d5c9600d](https://github.com/sophgo/bootloader-riscv/commit/95c8a85d5c9600d) at 2024-12-09 22:19:51)

  > Signed-off-by: JianHang Wu &lt;jianhang.wu@sophgo.com&gt;
  >
+ Scripts:do some optimizations. (@JianHang Wu in [1cdf8237a80d7be](https://github.com/sophgo/bootloader-riscv/commit/1cdf8237a80d7be) at 2024-12-09 09:35:12)

  > -add overlap checking, error reporting, info print functionality in gen_firmware_xml.c.
  > -remove some redundant files(gen_spi_flash.c and gen_sg2044r_spi_flash.c,etc).
  > If you need to add new board-level firmware, please follow the example to add the corresponding information at the head of gen_firmware_xml.c file. Additionally, add or modify the relevant functions in envsetup.sh (including specifying the release-note path and macros, etc).
  > Signed-off-by: JianHang Wu &lt;jianhang.wu@sophgo.com&gt;
  >
+ script: modify fw path for bm1690. (@dong.yang in [fe1796a58b3f17f](https://github.com/sophgo/bootloader-riscv/commit/fe1796a58b3f17f) at 2024-12-05 03:35:33)

  > Signed-off-by: dong.yang &lt;dong.yang@sophgo.com&gt;
  >
+ scripts: refine mango and sg2044 build scripts (@Jingyu Li in [828af44ad55f38b](https://github.com/sophgo/bootloader-riscv/commit/828af44ad55f38b) at 2024-12-03 12:26:43)

  > - Moved the DTB copy earlier to avoid issues with kernel Makefile version or
  >   rpmbuild tool version inconsistencies.
  > - FSBL source code is not publicly available; the daily build system updates
  >   the SG2044 binary at a fixed link and will automatically download it if
  >   missing locally.
  >   Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;
  >
+ scripts: fix build_rv_euler_kernel bug (@Jingyu Li in [a052f452e8c1211](https://github.com/sophgo/bootloader-riscv/commit/a052f452e8c1211) at 2024-11-29 06:18:22)

  > Different versions of the Linux kernel have varying build paths.
  > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;
  >
+ scripts: refine build process (@Jingyu Li in [4e5a4f9fe786b09](https://github.com/sophgo/bootloader-riscv/commit/4e5a4f9fe786b09) at 2024-11-28 08:00:23)

  > - Add DTB generation to build_rv_ubuntu/euler_kernel.
  > - Only copy the DTB file corresponding to the specified $CHIP into the firmware
  >   directory.
  > - For SG2044, Remove the LinuxBoot binaries when build_rv_*_image
  >   process; remove the LinuxBoot build process when build_rv_firmware.
  >   Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;
  >
+ modify the packaging scripts and add packaging support for SG2044 firmware (@wujianhang in [a60c5e4a38a7463](https://github.com/sophgo/bootloader-riscv/commit/a60c5e4a38a7463) at 2024-11-27 13:48:45)
+ scripts: revert build_rv_pcie_zsbl for BM1690. (@dong.yang in [7d5fa90c035fbc0](https://github.com/sophgo/bootloader-riscv/commit/7d5fa90c035fbc0) at 2024-11-27 13:04:09)

  > Now we use PCIe zsbl config for BM1690 in sg2260-pld branch,
  > so keep this cmd until BM1690 switch to zsbl master branch.
  > Signed-off-by: dong.yang &lt;dong.yang@sophgo.com&gt;
  >
+ scripts: remove checkout op when building EDK II (@Jingyu Li in [fc17795954f4b29](https://github.com/sophgo/bootloader-riscv/commit/fc17795954f4b29) at 2024-11-27 10:02:39)

  > In the daily-build system, the checkout operation synchronizes remote changes
  > stored in the refs/remotes/* space. However, if we also perform a checkout
  > during the local build process, the local changes in the refs/heads/* space can
  > lead to synchronization issues, including potential version rollbacks.
  > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;
  >
+ scripts: Restore rpm build directory to default directory (@Xiaoguang Xing in [e39fa86943a382b](https://github.com/sophgo/bootloader-riscv/commit/e39fa86943a382b) at 2024-11-25 13:48:33)

  > Signed-off-by: Xiaoguang Xing &lt;xiaoguang.xing@sophgo.com&gt;
  >
+ scripts: fix rpm&#x27;s builddir when linux ver &gt;&#x3D; 6.10 (@sharim in [874948fdc477ec7](https://github.com/sophgo/bootloader-riscv/commit/874948fdc477ec7) at 2024-11-25 09:59:57)

  > Signed-off-by: sharim &lt;sharim.pyi@gmail.com&gt;
  >
+ script: Update BM1690 TPU scalar build helper (@Chao Wei in [bc3c4cc6995912d](https://github.com/sophgo/bootloader-riscv/commit/bc3c4cc6995912d) at 2024-11-22 04:23:08)
+ set max log size for ramdisk (@bokai.zeng in [7ad757c78418b1a](https://github.com/sophgo/bootloader-riscv/commit/7ad757c78418b1a) at 2024-11-20 22:07:26)
+ [tp]: redirect standard output and standard error to /dev/null. (@pbw in [ec1a1388d920ea4](https://github.com/sophgo/bootloader-riscv/commit/ec1a1388d920ea4) at 2024-11-20 22:07:10)
+ changed ssh key right for ssh service (@bokai.zeng in [405c658aa0c2ae5](https://github.com/sophgo/bootloader-riscv/commit/405c658aa0c2ae5) at 2024-11-19 10:56:03)
+ sctipt:sg2042::remove single &#x60;popd&#x60; (@sharim in [1b096738d14a637](https://github.com/sophgo/bootloader-riscv/commit/1b096738d14a637) at 2024-11-19 09:17:49)

  > In function build_rv_euler_image, there is only a &#x60;popd&#x60;
  > without &#x60;pushd&#x60;, which caused &quot;directory stack empty&quot; error
  > Signed-off-by: sharim &lt;sharim.pyi@gmail.com&gt;
  >
+ scripts:gen_sg2042_image:avoid returning non-zero value on exit (@chunzhi.lin in [133e2f45f56ad13](https://github.com/sophgo/bootloader-riscv/commit/133e2f45f56ad13) at 2024-11-19 05:45:51)

  > When CHIP_NUM&#x3D;single, [ -e /etc/systemd/system/powergood.service] return 1,
  > this will be considered as a compilation problem and exit directly because the building environment has executed &#x27;set -e&#x27;.
  > Signed-off-by: chunzhi.lin &lt;chunzhi.lin@sophgo.com&gt;
  >
+ scripts: Change kernel and rpm build directory to $RV_TOP_DIR/build/$CHIP/ (@Xiaoguang Xing in [d4a29ab08c6b8d3](https://github.com/sophgo/bootloader-riscv/commit/d4a29ab08c6b8d3) at 2024-11-19 04:54:52)

  > Signed-off-by: Xiaoguang Xing &lt;xiaoguang.xing@sophgo.com&gt;
  >
+ scripts: rename config.ini to conf.ini. (@dong.yang in [2eb4b78efa9e031](https://github.com/sophgo/bootloader-riscv/commit/2eb4b78efa9e031) at 2024-11-19 01:27:43)

  > zsbl will load conf.ini by name.
  > Signed-off-by: dong.yang &lt;dong.yang@sophgo.com&gt;
  >
+ add default ssh key (@bokai.zeng in [ab638222bcd7f2c](https://github.com/sophgo/bootloader-riscv/commit/ab638222bcd7f2c) at 2024-11-18 12:39:18)
+ script: add config file for bm1690. (@dong.yang in [a6d7969d820a463](https://github.com/sophgo/bootloader-riscv/commit/a6d7969d820a463) at 2024-11-18 12:38:54)

  > Signed-off-by: dong.yang &lt;dong.yang@sophgo.com&gt;
  >
+ scripts: modify TARGET to DBEUG of EDK II (@Jingyu Li in [a26da8921685bc3](https://github.com/sophgo/bootloader-riscv/commit/a26da8921685bc3) at 2024-11-15 10:43:26)

  > In the development phase, modify compilation TARGET to DEBUG from RELEASE to
  > show more debug information when running EDK II.
  > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;
  >
+ adjust order of modins (@shuning.han in [abab01e63d84600](https://github.com/sophgo/bootloader-riscv/commit/abab01e63d84600) at 2024-11-13 09:19:24)

  > Signed-off-by: shuning.han &lt;shuning.han@sophgo.com&gt;
  >
+ Add and enable powergood signal service in SG2042 multi-chips server (@chunzhi.lin in [d531df05aad8a3f](https://github.com/sophgo/bootloader-riscv/commit/d531df05aad8a3f) at 2024-11-13 08:35:45)

  > The second linux kernel may be stuck for an infinite time due to failure
  > to mount rootfs normally, users couldn&#x27;t reconnect to this system after executing reboot because of the problem.
  > within five minutes after power-on, the BMC will detect the power good signal of successfully entry into linux system.
  > If no signal is detected, BMC will notify the CPLD to restart.
  > Signed-off-by: chunzhi.lin &lt;chunzhi.lin@sophgo.com&gt;
  >
+ revise rp scripts error (@shuning.han in [44086cd151833d4](https://github.com/sophgo/bootloader-riscv/commit/44086cd151833d4) at 2024-11-12 08:19:41)
+ update rp scripts (@shuning.han in [cfd8ff81f924fa4](https://github.com/sophgo/bootloader-riscv/commit/cfd8ff81f924fa4) at 2024-11-08 11:42:10)

  > Signed-off-by: shuning.han &lt;shuning.han@sophgo.com&gt;
  >
+ script: modify rp deamon path (@shuning.han in [6b216f51195c666](https://github.com/sophgo/bootloader-riscv/commit/6b216f51195c666) at 2024-11-05 13:00:34)
+ script: add build_rv_ramdisk_ci for Jenkins. (@dong.yang in [765703f4d0f8e24](https://github.com/sophgo/bootloader-riscv/commit/765703f4d0f8e24) at 2024-11-05 09:42:41)

  > User can use build_rv_ramdisk ap/rp/tp/mini to build cpio, but CI
  > should use build_rv_ramdisk_ci to check file.
  > Signed-off-by: dong.yang &lt;dong.yang@sophgo.com&gt;
  >
+ update rp ramdisk package (@shuning.han in [4328faf44b0bf5d](https://github.com/sophgo/bootloader-riscv/commit/4328faf44b0bf5d) at 2024-11-01 02:26:22)
+ script:bugfix:: remove Image.gz from rp bindeb-pkg make command (@sharim in [a5bfbdf7b91cead](https://github.com/sophgo/bootloader-riscv/commit/a5bfbdf7b91cead) at 2024-10-30 10:06:38)

  > Image.gz is one of the dependencies of bindeb-pkg,
  > compilation may fail with multiple threads
  > Signed-off-by: sharim &lt;sharim.pyi@gmail.com&gt;
  >
+ DistroImage: Update SG2044 distro images (@Chao Wei in [e254458f562ff47](https://github.com/sophgo/bootloader-riscv/commit/e254458f562ff47) at 2024-10-30 06:15:51)
+ script: build linux-header for rp ramdisk insmod ko. (@dong.yang in [51f7945f709e09d](https://github.com/sophgo/bootloader-riscv/commit/51f7945f709e09d) at 2024-10-27 01:49:47)

  > use cmd:
  > build_rv_kernel rp pkg
  > to package deb for rp ramdisk.
  > Signed-off-by: dong.yang &lt;dong.yang@sophgo.com&gt;
  >

## [sophgo-edk2(master)](https://github.com/sophgo/sophgo-edk2/tree/master)

+ Refine README (@Jingyu Li in [9c2ed89d285d4e5](https://github.com/sophgo/sophgo-edk2/commit/9c2ed89d285d4e5) at 2024-12-12 02:53:07)

  > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;
  >
+ UnitTestFrameworkPkg: Use TianoCore mirror of subhook submodule (@Jingyu Li in [12bb54ecd01fd89](https://github.com/sophgo/sophgo-edk2/commit/12bb54ecd01fd89) at 2024-11-05 05:44:33)

  > Change subhook url from https://github.com/Zeex/subhook to
  > https://github.com/tianocore/edk2-subhook because old url is
  > no longer available.
  > Also align .gitmodules file to use consistent LF line endings.
  > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;
  >
