#!/usr/bin/env bash

export RISCV64_LINUX_CROSS_COMPILE=riscv64-unknown-linux-gnu-
export RISCV64_ELF_CROSS_COMPILE=riscv64-unknown-elf-
export RV_ZSBL_SRC_DIR=$GITHUB_WORKSPACE/zsbl
export RV_SBI_SRC_DIR=$GITHUB_WORKSPACE/opensbi
export RV_EDKII_SRC_DIR=$GITHUB_WORKSPACE/sophgo-edk2
export RV_KERNEL_SRC_DIR=$GITHUB_WORKSPACE/linux-riscv
export PATH=${TOOLCHAIN_HOME}/bin:$PATH
