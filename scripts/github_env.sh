#!/usr/bin/env bash

export RISCV64_LINUX_CROSS_COMPILE=riscv64-linux-gnu-
export RISCV64_ELF_CROSS_COMPILE=riscv64-unknown-elf-
export RV_ZSBL_SRC_DIR=$GITHUB_WORKSPACE/zsbl
export RV_SBI_SRC_DIR=$GITHUB_WORKSPACE/opensbi
export RV_KERNEL_SRC_DIR=$GITHUB_WORKSPACE/linux-riscv
export PATH=${ELF_TOOLCHAIN_HOME}/bin:$PATH
