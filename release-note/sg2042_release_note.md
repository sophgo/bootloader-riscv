# 20261015

## bootloader-riscv
branch: master \
tag: NA \
commit: ccf5eaaa9122ee5f18d33dbfa8bb0d021e4cdd25

+ SG2042: Add release script

## sophgo-edk2
branch: devel-sg2042 \
tag: sg2042_sophgo-edk2_20261015 \
commit: bafa5020e9daa9e37584a1637e4e04ae6d24fdfd

+ BIOS v1.5.1 release, see sg2042_firmware_release_note.md

## linux-riscv
branch: sg2042-dev-6.6 \
tag: SG2042_Linux-6.6.127_v20260908 \
commit: d11e87070a4d3cba5734177e1d52ba6f725cf88f

+ No update

# 20261012

## bootloader-riscv
branch: master \
tag: NA \
commit: fcc74ae19ee945faa726577f9452ae5450a1353b

+ No update

## sophgo-edk2
branch: devel-sg2042 \
tag: sg2042_sophgo-edk2_20260617 \
commit: 23808ac8f0d18be05983b134f064331159519ae3

+ BIOS v1.5.0 release, see sg2042_firmware_release_note.md

## linux-riscv
branch: sg2042-dev-6.6 \
tag: SG2042_Linux-6.6.127_v20260908 \
commit: d11e87070a4d3cba5734177e1d52ba6f725cf88f

+ SG2042: Add Cambricon MLU370 in MSI-X white list

# 20260714

## bootloader-riscv
branch: master \
tag: NA \
commit: 80fbc1294001c80ab777f251652cca9eb4e896b7

+ No update

## sophgo-edk2
branch: devel-sg2042 \
tag: sg2042_sophgo-edk2_20260617 \
commit: cd2d36fde3e0247a91fdb192f17882a4dc317159

+ No update

## linux-riscv
branch: sg2042-dev-6.6 \
tag: SG2042_Linux-6.6.127_v20260706 \
commit: 97c1115b13cd15ffe33a4168e78727c1cd0e9e8e

+ irqchip/sifive-plic: fix stuck in-progress IRQ on affinity migration

# 20260622

## bootloader-riscv
branch: master \
tag: NA \
commit: cc238d22c14d111f2885b9c86ad56aa7df63268f

+ No update

## sophgo-edk2
branch: devel-sg2042 \
tag: sg2042_sophgo-edk2_20260617 \
commit: cd2d36fde3e0247a91fdb192f17882a4dc317159

+ SG2042: v1.4.3 BIOS release
+ SG2042: fixbug, virtual timer may never expired
+ SG2042: Set PCIe max payload supported to 128.
+ SG2042: Slow down virtual timer update frequency
+ SG2042: Reset PCIe QoS from highest to normal
+ SG2042: Fixbug, Wrong PCIe controller is used in MCFG
+ SG2042: Delete ethernet in DSDT

## linux-riscv
branch: sg2042-dev-6.6 \
tag: SG2042_Linux-6.6.127_v20260611 \
commit: ba8bf477523bd90dc33d083d94b0f0eff79186dc

+ Fixbug: memory leak in pcie controller driver
+ SG2042: enable lr/sc live lock workaround

# 20260424

## bootloader-riscv
branch: master \
tag: NA \
commit: 35b9f7a0d90164a1bed3fc68d6911133fd6c69eb

+ No update

## sophgo-edk2
branch: devel-sg2042 \
tag: sg2042_sophgo-edk2_20260424 \
commit: 0538a9493cf14b6b383842f55918a0e38d4149ac

+ SG2042: Modify setup hot key prompt from ESCAPE to F2

## linux-riscv
branch: sg2042-dev-6.6 \
tag: SG2042_Linux-6.6.127_v20260402 \
commit: 641c5b68a4595cb6ab45cbfa6b8b3d7a165c3f76

+ No update

# 20260413

## bootloader-riscv
branch: master \
tag: NA \
commit: 35b9f7a0d90164a1bed3fc68d6911133fd6c69eb

+ No update

## sophgo-edk2
branch: devel-sg2042 \
tag: sg2042_sophgo-edk2_20260408 \
commit: d8426e472fdea508207ae3ff99ad472f4c089715

+ No update

## linux-riscv
branch: sg2042-dev-6.6 \
tag: SG2042_Linux-6.6.127_v20260402 \
commit: 641c5b68a4595cb6ab45cbfa6b8b3d7a165c3f76

+ SG2042: Enable AST PCIe based RTC driver
+ SG2042: Fixbug, setting PCIe ATU with wrong value

# 20260408

## bootloader-riscv
branch: master \
tag: NA \
commit: 9bc4e6ba249fffed0dba5901f4ec60e600ed45a7

+ No update

## sophgo-edk2
branch: devel-sg2042 \
tag: sg2042_sophgo-edk2_20260408 \
commit: d8426e472fdea508207ae3ff99ad472f4c089715

+ Firmware v1.4.1 release

## linux-riscv
branch: sg2042-dev-6.6 \
tag: SG2042_Linux-6.6.127_v20260402 \
commit: eea78441367f0b8deaac83dee9c5827f7d95e638

+ No update

# 20260407

## bootloader-riscv
branch: master \
tag: NA \
commit: 5975ccaa292567472dbaf5e206404a5c556de661

+ SG204x: Move firmware release note to sophgo-edk2
+ Don't update binaries in git repo
+ SG2042: Using zsbl binaries in edk2-non-osi
+ SG2042: Copy zsbl binaries to edk2-non-osi
+ SG2044: Update ci after fsbl.bin removed
+ SG2044: Move fsbl.bin to sophgo-edk2

## sophgo-edk2
branch: devel-sg2042 \
tag: sg2042_sophgo-edk2_20260407 \
commit: 

+ Firmware v1.4.0 release

## linux-riscv
branch: sg2042-dev-6.6 \
tag: SG2042_Linux-6.6.127_v20260402 \
commit: eea78441367f0b8deaac83dee9c5827f7d95e638

+ Fix python2 syntax in decode_msr.py
+ Add all segments of SG2042 to PCI ecam quirk list
+ SG2042: Sync defconfig with openEuler 24.03 LTS SP3
+ drivers/net: Fix dwmac phy_node with wrong types
+ RISC-V: Add defines for SBI debug console extension
+ RISC-V: Add SBI debug console helper routines

# 20260318

## bootloader-riscv
branch: master \
tag: NA \
commit: 0602ca18b7f8fe9c27ab4c2cf7e2b425d7729cc7

+ Base release note

## sophgo-edk2
branch: devel-sg2042 \
tag: NA \
commit: 68f1225b0cf6b906457082cbf3aa738c291c0113

+ Base release note

## linux-riscv
branch: sg2042-dev-6.6 \
tag: NA \
commit: 9ccc697c1e41f402fad747a45d9c818b489e528a

+ Base release note
