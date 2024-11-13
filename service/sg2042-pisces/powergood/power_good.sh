#!/bin/bash
#

echo 498 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio498/direction
echo 1 > /sys/class/gpio/gpio498/value
echo pull high
sleep 1
echo 0 > /sys/class/gpio/gpio498/value 
echo pull low
echo 498 > /sys/class/gpio/unexport
