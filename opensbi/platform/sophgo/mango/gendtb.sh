#!/bin/bash

input_list='mango.dts virt.dts'

for input in $input_list; do
    output=`basename $input .dts`.dtb
    cpp -nostdinc -undef -x assembler-with-cpp $input | dtc -I dts -O dtb -o $output
done

