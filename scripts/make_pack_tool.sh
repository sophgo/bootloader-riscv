#!/bin/bash

if [ "$1" = "mango" ];then
    gcc $RV_SCRIPTS_DIR/make_xml.c -DSG2042 -o $RV_FIRMWARE_INSTALL_DIR/make_xml
    gcc $RV_SCRIPTS_DIR/pack/pack.c -DSG2042 -o $RV_FIRMWARE_INSTALL_DIR/pack
    RELEASED_NOTE_MD="$RELEASED_NOTE_PATH/sg2042_release_note.md"
    cp $RV_FIRMWARE/fip.bin  $RV_FIRMWARE_INSTALL_DIR/
elif [ "$1" = "sg2044" ];then
    gcc $RV_SCRIPTS_DIR/make_xml.c -DSG2044 -o $RV_FIRMWARE_INSTALL_DIR/make_xml
    gcc $RV_SCRIPTS_DIR/pack/pack.c -DSG2044 -o $RV_FIRMWARE_INSTALL_DIR/pack	
    RELEASED_NOTE_MD="$RELEASED_NOTE_PATH/sg2044_release_note.md"
    cp $RV_FIRMWARE/fsbl.bin  $RV_FIRMWARE_INSTALL_DIR/
fi	