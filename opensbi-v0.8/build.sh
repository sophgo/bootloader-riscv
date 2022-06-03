#!/bin/bash

SBI_PATH=$PWD
PLATFORM=sophgo/sg2040

function build_sbi()
{
    pushd $SBI_PATH
    make -j6 PLATFORM=$PLATFORM CROSS_COMPILE=riscv64-linux-gnu- \
        FW_TEXT_START=0x0 FW_JUMP_ADDR=0x00200000
    popd
}

function clean_sbi()
{
   pushd $SBI_PATH
   make distclean
   popd

}
