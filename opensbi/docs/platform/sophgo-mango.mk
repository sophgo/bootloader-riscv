SOPHGO Mango
============

parameters that passed to opensbi
---------------------------------
parameters that pass from previous stage to opensbi use general purpose register
*a0*, *a1*, and *a2*.

*a0*: boot hart id used by dynamic style firmware, this is not used in jump and
payload style firmware.

*a1*: device tree used by opensbi, and this device tree may be passed to next
stage(usually linux kernel or u-boot) depending on *FW_JUMP_FDT_ADDR*.

*a2*: dynamic loader *struct fw_dynamic_info*

*FW_FDT_PATH*
--------------
path of device tree used by opensbi. generally speaking, opensbi uses device
tree passed from previous stage which passed by general purpose register *a1*,
but it can be overwrited by specifying another device tree blob using
*FW_FDT_PATH* macro.

```
make FW_FDT_PATH='path/to/dtb'
```

after that, *a1* is not needed by opensbi

yet another way set this variable is setting variables in plarform specific
makefiles, like config.mk located at platform directory. one can add below lines
in platform config.mk

```
FW_FDT_PATH='path/to/dtb'
```

opensbi will link this device tree blob into its memory space by include binary
in assembly code.

```
	.globl fw_fdt_bin

fw_fdt_bin:             
	.incbin FW_FDT_PATH
```

*FW_JUMP_FDT_ADDR*
------------------
address of device tree which passed to next stage, maybe kernel or u-boot.
the default device tree passed to next stage is the one opensbi used itself.
but we can set this variable to force opensbi pass another device tree to next
stage.  previous loader should load this device tree blob to memory before
jump to opensbi.

like *FW_FDT_PATH*, we can change it by add extra arguments when building or set 
*FW_FDT_PATH* in config.mk

```
make FW_JUMP_FDT_ADDR=0x20000000
```

or add below code in config.mk

```
FW_JUMP_FDT_ADDR=0x20000000
```

mango choice
------------
1. setup *FW_FDT_PATH* in config.mk, specify a device tree blob for opensbi
2. setup *FW_JUMP_FDT_ADDR*in config.mk, specify a device tree blob for
linux kernel

boot hart id not used used by firmware jump. now we can directy load opensbi to
memory without a pre-loader.

memory layout
-------------

00000000 - 00200000	: 0 - 2M opensbi, including *FW_FDT_PATH* dtb

00200000 - 20000000	: 2M - 512M linux kernel *FW_JUMP_ADDR*

20000000 - 30000000	: 512M - 768M kernel device tree blob *FW_JUMP_FDT_ADDR*

30000000 - 40000000	: 768M - 1G ram disk

mango opensbi device tree
-------------------------
modify linux kernel device tree as opensbi device tree
1. *intc: interrupt-controller*

from *compatible = "riscv,plic0"* to *compatible = "thead,c900-plic"*

when compatible with "thead,c900-plic", interrupt delegate will effect on when
plic chip probe
