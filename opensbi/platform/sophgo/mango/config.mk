# Compiler flags

PLAT_MANGO = y

PLAT_MANGO_VHARTID = y
PLAT_MANGO_MTIMER = y
PLAT_MANGO_DISDVM = y

PLAT_MANGO_FLAGS = -DPLAT_MANGO

ifeq ($(strip $(PLAT_MANGO_VHARTID)), y)
  PLAT_MANGO_FLAGS += -DPLAT_MANGO_VHARTID
endif

ifeq ($(strip $(PLAT_MANGO_MTIMER)), y)
  PLAT_MANGO_FLAGS += -DPLAT_MANGO_MTIMER
endif

ifeq ($(strip $(PLAT_MANGO_DISDVM)), y)
  PLAT_MANGO_FLAGS += -DPLAT_MANGO_DISDVM
endif

platform-cppflags-y = $(PLAT_MANGO_FLAGS)
platform-cflags-y = $(PLAT_MANGO_FLAGS)
platform-asflags-y = $(PLAT_MANGO_FLAGS)
platform-ldflags-y = $(PLAT_MANGO_FLAGS)

# Blobs to build
FW_TEXT_START = 0x00000000

FW_FDT_PATH = $(platform_src_dir)/mango.dtb

FW_JUMP_FDT_ADDR = $(shell printf "0x%X" $$(($(FW_TEXT_START) + 0x2000000)))

FW_JUMP = y
ifeq ($(PLATFORM_RISCV_XLEN), 32)
  FW_JUMP_ADDR = $(shell printf "0x%X" $$(($(FW_TEXT_START) + 0x400000)))
else
  FW_JUMP_ADDR = $(shell printf "0x%X" $$(($(FW_TEXT_START) + 0x200000)))
endif

