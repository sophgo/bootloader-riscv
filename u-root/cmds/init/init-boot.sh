#!/bin/sh
# Read the random number first to avoid dhcp using random number timeout
dd if=/dev/urandom of=stdout bs=4 count=1
# pxeboot or localboot
multiboot
