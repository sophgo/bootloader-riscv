# 1.2.0_2025-06-09

## [zsbl(master)](https://github.com/sophgo/zsbl/tree/master)

+ Add I2C3 node in DTS for the RTC in SG2044 socket board. (@zhouwei.zhang in [98f95a29f463099](https://github.com/sophgo/zsbl/commit/98f95a29f463099) at 2025-05-20 02:43:48)
    > Signed-off-by: zhouwei.zhang &lt;zhouwei.zhang@sophgo.com&gt;

+ Update major and minor version to 2.1.x (@Chao Wei in [f7b3966692ccd68](https://github.com/sophgo/zsbl/commit/f7b3966692ccd68) at 2025-05-16 12:08:10)
    > New features added, set major from 1 to 2
    > Common bugs fixed, set minor from 0 to 1

+ Update all ini files (@kun-chang in [598cef8f8167e3e](https://github.com/sophgo/zsbl/commit/598cef8f8167e3e) at 2025-04-27 12:07:12)
    > - Update CPU frequency.
    > - Delete BIOS information.
    > Signed-off-by: kun-chang &lt;kun.chang@sophgo.com&gt;

+ Correct the gpio number binding for reboot (@kun-chang in [04890ec72712949](https://github.com/sophgo/zsbl/commit/04890ec72712949) at 2025-04-22 03:07:51)
    > Signed-off-by: kun-chang &lt;kun.chang@sophgo.com&gt;

+ SG2044: fixbug, linux,domain doesn&#x27;t match pcie hardware ID (@Chao Wei in [085fa57c8ded608](https://github.com/sophgo/zsbl/commit/085fa57c8ded608) at 2025-04-19 06:52:33)

+ Add sg2044-sra3.dtso and update all *conf.ini (@kun-chang in [65ca399b089b65d](https://github.com/sophgo/zsbl/commit/65ca399b089b65d) at 2025-04-17 13:08:48)
    > Signed-off-by: kun-chang &lt;kun.chang@sophgo.com&gt;

+ Modify to read secure boot flag and public key hash from ‌eFuse0‌ (@Jianhang Wu in [33a6e22653cbc89](https://github.com/sophgo/zsbl/commit/33a6e22653cbc89) at 2025-04-17 02:48:49)
    > Signed-off-by: Jianhang Wu &lt;jianhang.wu@sophgo.com&gt;

+ fixbug, ini parser doesn&#x27;t work well if \r\n as new line (@Chao Wei in [ab4cb7cb70649d7](https://github.com/sophgo/zsbl/commit/ab4cb7cb70649d7) at 2025-04-16 13:42:24)

+ filter out devices without reg property (@Chao Wei in [68b22c49c29e8ab](https://github.com/sophgo/zsbl/commit/68b22c49c29e8ab) at 2025-04-16 07:42:26)

+ SG2044: Add clock and subctrl for opensbi cppc devices (@Chao Wei in [882239d4035ddeb](https://github.com/sophgo/zsbl/commit/882239d4035ddeb) at 2025-04-16 07:42:03)

+ SG2044: Align linux,domain with IC design (@Chao Wei in [b95b653b885b877](https://github.com/sophgo/zsbl/commit/b95b653b885b877) at 2025-04-16 06:55:53)

+ Support FDT overlay (@Chao Wei in [aac2671eef6f8b7](https://github.com/sophgo/zsbl/commit/aac2671eef6f8b7) at 2025-04-14 08:40:24)
    > dtso(device tree source overlay) is in $arch/boot/dtso directory
    > dtso differences among boards.
    > dts differences among chips.

+ Refactor verification code (@Chao Wei in [06bdbe13cfb2106](https://github.com/sophgo/zsbl/commit/06bdbe13cfb2106) at 2025-04-14 03:43:26)

+ Move efi.c to common lib (@Chao Wei in [a8d52f9e8c2dc84](https://github.com/sophgo/zsbl/commit/a8d52f9e8c2dc84) at 2025-04-09 09:15:40)

+ Move verify.c to common lib, rename it to akcipher (@Chao Wei in [7459acbae42f04e](https://github.com/sophgo/zsbl/commit/7459acbae42f04e) at 2025-04-09 09:10:01)

+ SG2044: akcipher remove global variables (@Chao Wei in [68e8cfcdef2b634](https://github.com/sophgo/zsbl/commit/68e8cfcdef2b634) at 2025-04-09 08:54:53)

+ Fix: set secure boot disabled and fix the rsa verify bug (@Jianhang Wu in [44cb867eb158667](https://github.com/sophgo/zsbl/commit/44cb867eb158667) at 2025-04-09 08:39:55)
    > 1. The secure boot enable bit was used unexpected result in
    > activation of secure boot. Forcing it to be disabled.
    > 2. fix the rsa verify bug.
    > Signed-off-by: Jianhang Wu &lt;jianhang.wu@sophgo.com&gt;

+ SG2044: verify.c fix coding style (@Chao Wei in [8ed317b826ce54f](https://github.com/sophgo/zsbl/commit/8ed317b826ce54f) at 2025-04-08 12:39:40)

+ SG2044: Fix coding style, DER_INFO to der_info (@Chao Wei in [2e8734bf0f348a8](https://github.com/sophgo/zsbl/commit/2e8734bf0f348a8) at 2025-04-08 12:26:57)

+ Fix typo issue, akchipher should be akcipher (@Chao Wei in [d463fbca65d4490](https://github.com/sophgo/zsbl/commit/d463fbca65d4490) at 2025-04-08 12:21:06)

+ SG2044: pass zsbl dtb to opensbi and edk2 (@Chao Wei in [0dfce0b2f893361](https://github.com/sophgo/zsbl/commit/0dfce0b2f893361) at 2025-04-08 08:40:04)

+ SG2044: Generate CPPC information in dtb (@Chao Wei in [d6b433b9f4ca423](https://github.com/sophgo/zsbl/commit/d6b433b9f4ca423) at 2025-03-28 09:11:37)

+ fix a bug in pka clock initialization. (@Jianhang Wu in [ccac8cb2548c5a2](https://github.com/sophgo/zsbl/commit/ccac8cb2548c5a2) at 2025-03-27 12:45:34)
    > the pka clock enable will be set 1 after modify.
    > Signed-off-by: Jianhang Wu &lt;jianhang.wu@sophgo.com&gt;

+ SG2044: workaround of SN burn into DDR information by mistake (@Chao Wei in [9fa00941d679ad0](https://github.com/sophgo/zsbl/commit/9fa00941d679ad0) at 2025-03-26 06:53:55)
    > 1. If SN burn into DDR information by mistake, considor it as
    > 128GB DDR
    > 2. If DDR information is not valid, considor it as 128GB DDR
    > 3. Otherwise, using DDR information in eFuse

+ Alg: fix a bug, add elapka.elf file in pka/ which will be used in pka driver. (@Jianhang Wu in [b457f8d6233821a](https://github.com/sophgo/zsbl/commit/b457f8d6233821a) at 2025-03-19 04:19:25)
    > Signed-off-by: Jianhang Wu &lt;jianhang.wu@sophgo.com&gt;

+ Add secure boot function in zsbl. (@Jianhang Wu in [4d639fee26b4995](https://github.com/sophgo/zsbl/commit/4d639fee26b4995) at 2025-03-18 08:09:29)
    > The PKA driver has been added, supporting both ‌RSA (SHA256)‌ and ‌SM2 (SM3)‌ signature verification algorithms.
    > If the secure boot option is enabled in the efuse configuration, the original boot files must be augmented with ‌additional signature files and public keys‌.
    > Signed-off-by: Jianhang Wu &lt;jianhang.wu@sophgo.comn&gt;

+ riscv: conf: modify processor name (@Jingyu Li in [af8a0c2936926a3](https://github.com/sophgo/zsbl/commit/af8a0c2936926a3) at 2025-03-15 08:08:53)
    > Modify processor name from &quot;C920&quot; to &quot;SG2044&quot;.
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ SG2044: Add SRA3-40 conf.ini (@kun-chang in [22401b2ee7f37a7](https://github.com/sophgo/zsbl/commit/22401b2ee7f37a7) at 2025-03-14 04:04:08)
    > Signed-off-by: kun-chang &lt;kun.chang@sophgo.com&gt;

+ Add memory test command (@Chao Wei in [b5e326b59254976](https://github.com/sophgo/zsbl/commit/b5e326b59254976) at 2025-03-14 02:59:35)

+ Remove legacy IO framework header files (@Chao Wei in [92d8941a646b780](https://github.com/sophgo/zsbl/commit/92d8941a646b780) at 2025-03-12 11:40:26)

+ SGCFG: Enlarge conf.ini buffer from 4K to 8K (@Chao Wei in [786b3f30118375d](https://github.com/sophgo/zsbl/commit/786b3f30118375d) at 2025-03-05 05:58:09)
    > Fix bug, broken conf.ini in flash.

+ drivers: mtd: adjust spif SCLK from 25 MHz to 12.5 MHz (@kun-chang in [f9d8a9443801869](https://github.com/sophgo/zsbl/commit/f9d8a9443801869) at 2025-03-05 05:56:25)
    > Signed-off-by: kun-chang &lt;kun.chang@sophgo.com&gt;

+ plat: correct the spelling error in the pcie ini string (@fengchun.li in [c4a4b3313d646e8](https://github.com/sophgo/zsbl/commit/c4a4b3313d646e8) at 2025-03-01 23:31:12)
    > plat: correct the spelling error in the pcie ini string
    > Signed-off-by: fengchun.li &lt;fengchun.li@sophgo.com&gt;

+ SG2044: Remove work-mode in conf.ini (@Chao Wei in [85823ff230d229e](https://github.com/sophgo/zsbl/commit/85823ff230d229e) at 2025-02-18 12:30:30)
    > Using ReservedMemory menu in EDK2 UI.
    > If 0 is set, means 2044 working at CPU mode, os can used all memory
    > installed on package, and TPU node is disabled in DSDT.
    > Otherwise, reserved memory specific by this menu, and TPU node is
    > enabled in DSDT.

+ SG2044: Modify vendor variable guid (@Jingyu Li in [a4f73cf7d0bd9ea](https://github.com/sophgo/zsbl/commit/a4f73cf7d0bd9ea) at 2025-02-18 12:27:16)
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ SG2044: Support reserve memory (@Chao Wei in [7574dcc053c567b](https://github.com/sophgo/zsbl/commit/7574dcc053c567b) at 2025-02-14 03:36:58)
    > Reserved memory size is read out from EDK2 variable store.
    > Variable ReservedMemorySize in EDK2 is in GB unit.

+ SG2044: support SoC mode (@Chao Wei in [6d10a8f26251f0c](https://github.com/sophgo/zsbl/commit/6d10a8f26251f0c) at 2025-02-08 07:44:22)
    > Get working mode from config.ini
    > Default working mode is CPU
    > In SoC mode, available system memory will be half of installed.

+ bm1690:dts: some dtb size is over 4096, set dtb resize size 8192. (@dong.yang in [7136ab8f49d73ae](https://github.com/sophgo/zsbl/commit/7136ab8f49d73ae) at 2025-01-22 07:38:31)
    > Signed-off-by: dong.yang &lt;dong.yang@sophgo.com&gt;

+ SG2044: Add SRA3-40-8 conf.ini (@Chao Wei in [c161f4688d83e27](https://github.com/sophgo/zsbl/commit/c161f4688d83e27) at 2025-01-21 07:28:39)

+ add init config info for pcie node of dtb (@fengchun.li in [304480b61106a46](https://github.com/sophgo/zsbl/commit/304480b61106a46) at 2025-01-20 11:13:56)
    > implement the pcie cfg parameter parsing of conf.ini file
    > Signed-off-by: fengchun.li &lt;fengchun.li@sophgo.com&gt;

+ SG2044: Add PCIe node to dts dynamically (@Chao Wei in [8cc7667572a9fcb](https://github.com/sophgo/zsbl/commit/8cc7667572a9fcb) at 2025-01-18 11:46:19)
    > Default configuration is 5RC.
    > PCIe owner should get PCIe topology from conf.ini.
    > Then add PCIe nodes to dtb by using these APIs.

+ bm1690: fix build_rv_tp_zsbl compile bug. (@dong.yang in [183856e21a1091b](https://github.com/sophgo/zsbl/commit/183856e21a1091b) at 2025-01-18 06:55:14)
    > 1. use %llx to display long long type data.
    > 2. reduce the code len in one line.
    > Signed-off-by: dong.yang &lt;dong.yang@sophgo.com&gt;

+ SG2044: Add fdt_dump_blob (@Chao Wei in [f1582b6ccb7d5c7](https://github.com/sophgo/zsbl/commit/f1582b6ccb7d5c7) at 2025-01-17 12:18:23)

+ tp delete clint-mswi node (@tingzhu.wang@sophgo.com in [f4c592d53cdc98a](https://github.com/sophgo/zsbl/commit/f4c592d53cdc98a) at 2025-01-14 08:33:27)
    > Signed-off-by: tingzhu.wang@sophgo.com &lt;tingzhu.wang@sophgo.com&gt;

+ SG2044: set initramfs in dtb (@Inochi Amaoto in [65ca7cf17a4a2f6](https://github.com/sophgo/zsbl/commit/65ca7cf17a4a2f6) at 2025-01-12 03:42:21)
    > As the initramfs address is generated by the firmware, it maybe
    > more suitable to set it in the dtb, which keeps bootargs clean.
    > Signed-off-by: Inochi Amaoto &lt;inochiama@gmail.com&gt;

+ SG2044: allow to set bootargs (@Inochi Amaoto in [64855cb273a3f44](https://github.com/sophgo/zsbl/commit/64855cb273a3f44) at 2025-01-12 03:42:21)
    > Keep the bootargs in the dtb is not favor, so add an option
    > in the conf.ini to set custom bootargs
    > Signed-off-by: Inochi Amaoto &lt;inochiama@gmail.com&gt;

+ lib/sgcfg: allow file load from fs root (@Inochi Amaoto in [2ce4d3a00144e5f](https://github.com/sophgo/zsbl/commit/2ce4d3a00144e5f) at 2025-01-10 12:55:49)
    > Many linux distribution build linux image under the
    > fs root. It is unwise to copy it to the vendor specific
    > dir.
    > Allow the sgfat load custom file from fs root.
    > Signed-off-by: Inochi Amaoto &lt;inochiama@gmail.com&gt;

+ bm1690: cli_loop(0) will cause zsbl into cmdline. (@dong.yang in [779440bd7d73f96](https://github.com/sophgo/zsbl/commit/779440bd7d73f96) at 2025-01-04 09:03:55)
    > In PCIe mode, zsbl should directly jump to the next level to
    > continue execution.
    > Signed-off-by: dong.yang &lt;dong.yang@sophgo.com&gt;

+ support getopt series functions (@Chao Wei in [d8a5994f48a23ff](https://github.com/sophgo/zsbl/commit/d8a5994f48a23ff) at 2024-12-31 15:01:47)

+ SG2044: remove c920 csr log on boot (@Chao Wei in [57dff4918865a5b](https://github.com/sophgo/zsbl/commit/57dff4918865a5b) at 2024-12-31 14:33:32)
    > add a command lscsr instead.
    > press j, enter console, then execute lscsr command

+ remove outdated efuse driver (@Chao Wei in [b6f2fd576b40d15](https://github.com/sophgo/zsbl/commit/b6f2fd576b40d15) at 2024-12-31 14:25:55)

+ add more device list commands (@Chao Wei in [66d995632cb323e](https://github.com/sophgo/zsbl/commit/66d995632cb323e) at 2024-12-31 14:23:08)

+ add command, list boot devices (@Chao Wei in [07753bc184d6f57](https://github.com/sophgo/zsbl/commit/07753bc184d6f57) at 2024-12-31 14:15:08)
    > lsbdev, list boot devices

+ add command, list all platform devices (@Chao Wei in [ce547abc97a4253](https://github.com/sophgo/zsbl/commit/ce547abc97a4253) at 2024-12-31 14:11:53)
    > lspdev, list platform devices

+ add console (@Chao Wei in [679cb81f20fbe19](https://github.com/sophgo/zsbl/commit/679cb81f20fbe19) at 2024-12-31 14:11:53)

+ SG2044: Auto generate memory information (@Chao Wei in [0e3bba0a8cf5071](https://github.com/sophgo/zsbl/commit/0e3bba0a8cf5071) at 2024-12-30 04:25:48)
    > Auto generate memory information by eFuse data

+ modify memory node in dtb automatically (@Chao Wei in [fa0fbce42bd0152](https://github.com/sophgo/zsbl/commit/fa0fbce42bd0152) at 2024-12-27 14:23:14)

+ follow device naming convension (@Chao Wei in [fe702a41a2562b2](https://github.com/sophgo/zsbl/commit/fe702a41a2562b2) at 2024-12-27 14:20:59)

+ add alias property in device (@Chao Wei in [a82264d8946a516](https://github.com/sophgo/zsbl/commit/a82264d8946a516) at 2024-12-27 14:20:59)

+ add nvmem device model (@Chao Wei in [8f9f41cabfdd7c6](https://github.com/sophgo/zsbl/commit/8f9f41cabfdd7c6) at 2024-12-27 14:20:59)
    > add nvmem device model
    > add its first device driver, sophgo efuse

+ SG2044: support geting dram information from efuse (@Chao Wei in [572f47fc5740d09](https://github.com/sophgo/zsbl/commit/572f47fc5740d09) at 2024-12-27 14:20:59)

+ fix conflict macro definitions (@Chao Wei in [4ec7ed9e1725cb6](https://github.com/sophgo/zsbl/commit/4ec7ed9e1725cb6) at 2024-12-27 14:20:59)

+ using alias to index boot devices (@Chao Wei in [455a9160aaf5885](https://github.com/sophgo/zsbl/commit/455a9160aaf5885) at 2024-12-27 14:20:59)

+ change tp memory layout of pcie mode (@tingzhu.wang@sophgo.com in [e287bbc15974dc7](https://github.com/sophgo/zsbl/commit/e287bbc15974dc7) at 2024-12-26 02:26:41)
    > Signed-off-by: tingzhu.wang@sophgo.com &lt;tingzhu.wang@sophgo.com&gt;

+ Modify the value of DDR data-rate in conf.ini (@lin fei in [fc1ca4037f53799](https://github.com/sophgo/zsbl/commit/fc1ca4037f53799) at 2024-12-25 12:51:56)
    > Signed-off-by: lin peng &lt;peng.lin@sophgo.com&gt;

+ Modify the conf.ini content according to SMBIOS specifications (@lin fei in [ae1bd24a1b30eac](https://github.com/sophgo/zsbl/commit/ae1bd24a1b30eac) at 2024-12-25 12:38:45)
    > - Remove the chassis-related content.
    > - Update the values for DDR, CPU, and cache sections according to SMBIOS specifications.
    > - Standardize the casing (uppercase/lowercase) in conf.ini.
    > Signed-off-by: lin peng &lt;peng.lin@sophgo.com&gt;

## [linux-riscv(sg2042-rel-6.1.31)](https://github.com/sophgo/linux-riscv/tree/sg2042-rel-6.1.31)

+ riscv: mm: Pre-allocate PGD entries for vmalloc/modules area (@Björn Töpel in [cf64537a8a87c21](https://github.com/sophgo/linux-riscv/commit/cf64537a8a87c21) at 2025-06-09 02:42:40)
    > The RISC-V port requires that kernel PGD entries are to be
    > synchronized between MMs. This is done via the vmalloc_fault()
    > function, that simply copies the PGD entries from init_mm to the
    > faulting one.
    > Historically, faulting in PGD entries have been a source for both bugs
    > [1], and poor performance.
    > One way to get rid of vmalloc faults is by pre-allocating the PGD
    > entries. Pre-allocating the entries potientially wastes 64 * 4K (65 on
    > SV39). The pre-allocation function is pulled from Jörg Rödel&#x27;s x86
    > work, with the addition of 3-level page tables (PMD allocations).
    > The pmd_alloc() function needs the ptlock cache to be initialized
    > (when split page locks is enabled), so the pre-allocation is done in a
    > RISC-V specific pgtable_cache_init() implementation.
    > Pre-allocate the kernel PGD entries for the vmalloc/modules area, but
    > only for 64b platforms.
    > Link: https://lore.kernel.org/lkml/20200508144043.13893-1-joro@8bytes.org/ # [1]
    > Signed-off-by: Björn Töpel &lt;bjorn@rivosinc.com&gt;
    > Reviewed-by: Alexandre Ghiti &lt;alexghiti@rivosinc.com&gt;
    > Link: https://lore.kernel.org/r/20230531093817.665799-1-bjorn@kernel.org
    > Signed-off-by: Palmer Dabbelt &lt;palmer@rivosinc.com&gt;
    > Signed-off-by: haijiao.liu &lt;haijiao.liu@sophgo.com&gt;

+ sophgo_mango_fedora_defconfig: enable CONFIG_HZ_1000 (@haijiao.liu in [22c7cd9d8e0a780](https://github.com/sophgo/linux-riscv/commit/22c7cd9d8e0a780) at 2025-03-19 09:35:32)
    > Due to issues with the server&#x27;s time synchronization, the system lacks
    > an hrtimer. To improve timer precision, HZ has been adjusted to 1000.
    > Signed-off-by: haijiao.liu &lt;haijiao.liu@sophgo.com&gt;

+ riscv: dts: sophgo: disable the on-chip Ethernet controller (@haijiao.liu in [f545e4f9a465a7d](https://github.com/sophgo/linux-riscv/commit/f545e4f9a465a7d) at 2025-01-09 09:53:42)
    > Signed-off-by: haijiao.liu &lt;haijiao.liu@sophgo.com&gt;

+ riscv: dts: sophgo: set PCIe controller 1 to support msix (@haijiao.liu in [0f45d8544a8441f](https://github.com/sophgo/linux-riscv/commit/0f45d8544a8441f) at 2025-01-09 09:34:52)
    > Signed-off-by: haijiao.liu &lt;haijiao.liu@sophgo.com&gt;

## [bootloader-riscv(master)](https://github.com/sophgo/bootloader-riscv/tree/master)

+ SG2044: v1.2.0 release (@Chao Wei in [69095919fa7c95c](https://github.com/sophgo/bootloader-riscv/commit/69095919fa7c95c) at 2025-05-16 12:50:16)

+ Replace leading white space with tab (@Chao Wei in [fe7367e21f354e1](https://github.com/sophgo/bootloader-riscv/commit/fe7367e21f354e1) at 2025-05-16 08:50:50)

+ ci: add sg2044 firmware build (@Han Gao in [bee9419323a7e75](https://github.com/sophgo/bootloader-riscv/commit/bee9419323a7e75) at 2025-05-12 09:15:36)
    > Signed-off-by: Han Gao &lt;rabenda.cn@gmail.com&gt;

+ fix sg2044 img (@Han Gao in [28439cee8b2d993](https://github.com/sophgo/bootloader-riscv/commit/28439cee8b2d993) at 2025-05-12 09:15:36)
    > Signed-off-by: Han Gao &lt;rabenda.cn@gmail.com&gt;

+ ci: rename build to build-sg2042 (@Han Gao in [20dacd5cb4f8f16](https://github.com/sophgo/bootloader-riscv/commit/20dacd5cb4f8f16) at 2025-05-12 09:15:36)
    > Signed-off-by: Han Gao &lt;rabenda.cn@gmail.com&gt;

+ [ap]:fix tpu_hang_info.sh addr (@yifei.gao in [4db9584bd4e3538](https://github.com/sophgo/bootloader-riscv/commit/4db9584bd4e3538) at 2025-05-12 09:14:31)

+ scripts:gen_sg2042_image:Fixed compilation error (@chunzhi.lin in [93766ff0c63c9bc](https://github.com/sophgo/bootloader-riscv/commit/93766ff0c63c9bc) at 2025-04-27 13:03:29)
    > Fixed the error of mounting /run directory conflict when compiling euler image
    > Signed-off-by: chunzhi.lin &lt;chunzhi.lin@sophgo.com&gt;

+ SG2044: Use RELEASE target as the default when building EDK2 (@Chao Wei in [3d24e423cd4ac3e](https://github.com/sophgo/bootloader-riscv/commit/3d24e423cd4ac3e) at 2025-04-25 11:25:17)

+ SG2044: Fixbug sg2044-evb.dtbo missing in prebuild image (@Chao Wei in [996c692bfb5ff39](https://github.com/sophgo/bootloader-riscv/commit/996c692bfb5ff39) at 2025-04-25 07:04:01)

+ Scripts: add public key and signature in firmware. (@Jianhang Wu in [70a87df5687a041](https://github.com/sophgo/bootloader-riscv/commit/70a87df5687a041) at 2025-04-25 06:03:37)
    > 1. A key pair was added to the scripts/key directory.
    > 2. The public key and signature information of each binary
    > file was embedded within the firmware.bin.
    > Signed-off-by: Jianhang Wu &lt;jianhang.wu@sophgo.com&gt;

+ Pack sra3.dtso to firmware and cp all dtso files to riscv64 for SG2044 (@kun-chang in [96aa467452c24be](https://github.com/sophgo/bootloader-riscv/commit/96aa467452c24be) at 2025-04-19 06:58:08)
    > Signed-off-by: kun-chang &lt;kun.chang@sophgo.com&gt;

+ Support zsbl fdt overlay. (@Chao Wei in [682cb8c4dcc3ffc](https://github.com/sophgo/bootloader-riscv/commit/682cb8c4dcc3ffc) at 2025-04-14 08:51:49)

+ Scripts: modify the packaging method for firmware.bin (@Jianhang Wu in [07033186b184b2f](https://github.com/sophgo/bootloader-riscv/commit/07033186b184b2f) at 2025-04-14 03:59:20)
    > 1. Cancell the method of setting parameters through XML files
    > 2. Add an automatic packaging tool which allows for unspecified offset
    > Signed-off-by: Jianhang Wu &lt;jianhang.wu@sophgo.com&gt;

+ fix(ap):correct some register reading and parsing (@yifei.gao in [fe8ee12039f69e4](https://github.com/sophgo/bootloader-riscv/commit/fe8ee12039f69e4) at 2025-04-07 02:30:24)

+ Scripts: Fixbug, Change the offset address of fw_dynamic.bin in flash (@Jianhang Wu in [0e60dc7066594c1](https://github.com/sophgo/bootloader-riscv/commit/0e60dc7066594c1) at 2025-04-03 06:31:10)
    > Change the offset of fw_dynamic.bin to meet the boundary requirements.
    > Signed-off-by: Jianhang Wu &lt;jianhang.wu@sophgo.com&gt;

+ feat(ap):add more detailed and readable log printing (@yifei.gao in [9958799ac686036](https://github.com/sophgo/bootloader-riscv/commit/9958799ac686036) at 2025-03-21 09:31:28)

+ add dump tpu register script (@tingzhu.wang@sophgo.com in [2a10aa8bc0c6e9b](https://github.com/sophgo/bootloader-riscv/commit/2a10aa8bc0c6e9b) at 2025-03-19 08:43:58)
    > Signed-off-by: tingzhu.wang@sophgo.com &lt;tingzhu.wang@sophgo.com&gt;

+ script: bm1690e: add build script for bm1690e. (@dong.yang in [16605a3ff005934](https://github.com/sophgo/bootloader-riscv/commit/16605a3ff005934) at 2025-03-12 04:16:40)
    > Signed-off-by: dong.yang &lt;dong.yang@sophgo.com&gt;

+ scripts: gen_sg2044_img: include kernel-devel package (@Jingyu Li in [da9412b9555d702](https://github.com/sophgo/bootloader-riscv/commit/da9412b9555d702) at 2025-03-06 23:27:35)
    > - Add kernel-devel RPM to the build process for development support.
    > - Refine kernel RPM installation pattern to target specific versions.
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ script: fix bootrom path error. (@dong.yang in [6cf46356c32a149](https://github.com/sophgo/bootloader-riscv/commit/6cf46356c32a149) at 2025-02-25 01:11:42)
    > bootrom is sophgo-2260&#x27;s sub-directory, should not place below
    > $RV_TOP_DIR.
    > Signed-off-by: dong.yang &lt;dong.yang@sophgo.com&gt;

+ SG2044: fixbug, grub config not updated after installation (@Chao Wei in [9febab1105b862b](https://github.com/sophgo/bootloader-riscv/commit/9febab1105b862b) at 2025-02-17 01:58:27)
    > 1. Using /boot/efi/EFI/openEuler/grub.cfg as the default grub
    > configuration. This configuration is also the default grub
    > config file on offical openEuler
    > 2. Call grub2-mkconfig after initrd generated. The hole file
    > is regenerated, not only add one entry into grub config. Follow
    > loongarch.
    > 3. This modification needs modify openEuler image. Change
    > /boot/efi/EFI/BOOT/BOOTRISCV64.EFI to offcial one.

+ script: delete CHIP&#x3D;bm1690 build script. (@dong.yang in [81c4eba01d4bb82](https://github.com/sophgo/bootloader-riscv/commit/81c4eba01d4bb82) at 2025-02-10 04:22:52)
    > Only use CHIP&#x3D;sg2044 to build image for chip.
    > Signed-off-by: dong.yang &lt;dong.yang@sophgo.com&gt;

+ scripts:sg2044:: only keep current version kernel pkgs (@sharim in [2826e6a85a59f65](https://github.com/sophgo/bootloader-riscv/commit/2826e6a85a59f65) at 2025-02-10 03:09:47)
    > Signed-off-by: sharim &lt;sharim.pyi@gmail.com&gt;

+ Fixed complie error for pkg build (@bokai.zeng in [073a4c45ecd6359](https://github.com/sophgo/bootloader-riscv/commit/073a4c45ecd6359) at 2025-02-08 07:16:46)
    > Signed-off-by: bokai.zeng &lt;bokai.zeng@sophgo.com&gt;

+ Add package cross-builder header debs command (@bokai.zeng in [113b1bc76599236](https://github.com/sophgo/bootloader-riscv/commit/113b1bc76599236) at 2025-02-07 09:04:20)
    > Signed-off-by: bokai.zeng &lt;bokai.zeng@sophgo.com&gt;

+ scripts:sg2044&amp;bm1690:: disable &#x27;pending kernel upgrade&#x27; dialog caused CI hang (@sharim in [b6edfb8b0be6eaf](https://github.com/sophgo/bootloader-riscv/commit/b6edfb8b0be6eaf) at 2025-02-07 05:12:36)
    > Signed-off-by: sharim &lt;sharim.pyi@gmail.com&gt;

+ scripts: pack_firmware_bin: increase fsbl.bin partition size (@Jingyu Li in [915260ce8eb334b](https://github.com/sophgo/bootloader-riscv/commit/915260ce8eb334b) at 2025-02-07 02:16:02)
    > The size of the original fsbl.bin has been increased. The corresponding partition
    > size should also be enlarged to prevent overlap with the subsequent partition.
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ scripts:sg2044:: fix openeuler native build func (@sharim in [05145196fdd977e](https://github.com/sophgo/bootloader-riscv/commit/05145196fdd977e) at 2025-02-06 08:46:04)
    > Signed-off-by: sharim &lt;sharim.pyi@gmail.com&gt;

+ bm1690: use EDK2 for boot. (@dong.yang in [2f3ea798bbefb48](https://github.com/sophgo/bootloader-riscv/commit/2f3ea798bbefb48) at 2025-02-06 07:34:45)
    > Signed-off-by: dong.yang &lt;dong.yang@sophgo.com&gt;

+ ci: update to actions/upload-artifact@v4 (@Han Gao in [2be977938c832bc](https://github.com/sophgo/bootloader-riscv/commit/2be977938c832bc) at 2025-02-05 01:44:41)
    > Signed-off-by: Han Gao &lt;rabenda.cn@gmail.com&gt;

+ script:sg2044:: support native compilation of openEuler (@sharim in [06789f32fd1c221](https://github.com/sophgo/bootloader-riscv/commit/06789f32fd1c221) at 2025-01-23 03:47:03)
    > Signed-off-by: sharim &lt;sharim.pyi@gmail.com&gt;

+ Scripts: modified the location for retrieving the firmware version number in release note. (@Jianhang Wu in [5e2f0c0afdfb1df](https://github.com/sophgo/bootloader-riscv/commit/5e2f0c0afdfb1df) at 2025-01-22 01:03:31)
    > Signed-off-by: Jianhang Wu &lt;jianhang.wu@sophgo.comn&gt;

+ SG2044: Release: v1.1.0 (SDK 20250121) (@Jingyu Li in [6d0d783c0f04335](https://github.com/sophgo/bootloader-riscv/commit/6d0d783c0f04335) at 2025-01-21 12:59:45)
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ Scripts: modified the offsets of the firmware in flash. (@Jianhang Wu in [c25f1b8c0ec0e8f](https://github.com/sophgo/bootloader-riscv/commit/c25f1b8c0ec0e8f) at 2025-01-21 05:52:49)
    > Signed-off-by: Jianhang Wu &lt;jianhang.wu@sophgo.comn&gt;

+ github:workflows: Update linux-riscv branch (@Xiaoguang Xing in [dbe00c1f1163eb9](https://github.com/sophgo/bootloader-riscv/commit/dbe00c1f1163eb9) at 2025-01-20 03:46:46)
    > Signed-off-by: Xiaoguang Xing &lt;xiaoguang.xing@sophgo.com&gt;

+ Scripts: modified the matching method for version info in the format of x.x.x_yyyy-mm-dd and optimized coding format of &quot;gen/pack_firmware*&quot;. (#170) (@wu-jian-hang in [63119b4c2841cef](https://github.com/sophgo/bootloader-riscv/commit/63119b4c2841cef) at 2025-01-16 11:57:47)
    > Signed-off-by: Jianhang Wu &lt;jianhang.wu@sophgo.comn&gt;
    > Co-authored-by: Jianhang Wu &lt;jianhang.wu@sophgo.comn&gt;

+ Merge pull request #172 from SophgoChaoWei/master (@SophgoChaoWei in [f4e75693a0763fc](https://github.com/sophgo/bootloader-riscv/commit/f4e75693a0763fc) at 2025-01-16 02:56:41)
    > SG2044: Add kernel.spec of openEuler 24.03

+ SG2044: Add kernel.spec of openEuler 24.03 (@Chao Wei in [d66d48d2af5e98d](https://github.com/sophgo/bootloader-riscv/commit/d66d48d2af5e98d) at 2025-01-15 14:06:57)
    > This spec helps creating rpm packages which built from linux
    > kernel. These packages are
    > bpftool
    > bpftool-debuginfo
    > kernel
    > kernel-debuginfo
    > kernel-debugsource
    > kernel-devel
    > kernel-headers
    > kernel-source
    > kernel-tools
    > kernel-tools-debuginfo
    > kernel-tools-devel
    > perf
    > perf-debuginfo
    > python3-perf
    > python3-perf-debuginfo

+ script:ap daemon remove redirects (@tingzhu.wang@sophgo.com in [89856cccc0358c7](https://github.com/sophgo/bootloader-riscv/commit/89856cccc0358c7) at 2025-01-15 08:50:29)
    > Signed-off-by: tingzhu.wang@sophgo.com &lt;tingzhu.wang@sophgo.com&gt;

+ SG2044: Release: v1.0.0 (@Jingyu Li in [24fb413135c1516](https://github.com/sophgo/bootloader-riscv/commit/24fb413135c1516) at 2025-01-13 09:54:57)
    > Signed-off-by: Jingyu Li &lt;jingyu.li01@sophgo.com&gt;

+ change ramdisk get ip from /proc/sgdrv/vethip (@xiangwen.jiang in [8b7976ee00ccb06](https://github.com/sophgo/bootloader-riscv/commit/8b7976ee00ccb06) at 2025-01-08 09:45:46)
    > Signed-off-by: xiangwen.jiang &lt;xiangwen.jiang@sophgo.com&gt;

+ scripts: modify BM1690 boot file address. (@dong.yang in [1491742c520fa58](https://github.com/sophgo/bootloader-riscv/commit/1491742c520fa58) at 2025-01-03 08:04:42)
    > Signed-off-by: dong.yang &lt;dong.yang@sophgo.com&gt;

+ pcie mode rp use zsbl.bin (@tingzhu.wang@sophgo.com in [05231d991d1a43e](https://github.com/sophgo/bootloader-riscv/commit/05231d991d1a43e) at 2024-12-26 07:14:38)
    > Signed-off-by: tingzhu.wang@sophgo.com &lt;tingzhu.wang@sophgo.com&gt;

+ change the address of ip (@tingzhu.wang@sophgo.com in [070a738f8a53632](https://github.com/sophgo/bootloader-riscv/commit/070a738f8a53632) at 2024-12-26 02:49:09)
    > Signed-off-by: tingzhu.wang@sophgo.com &lt;tingzhu.wang@sophgo.com&gt;

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
