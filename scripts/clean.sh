#!/bin/bash

cd ~/project/khadas/ubuntu/

## images
echo -e "\nCleaning: images..."
rm -rf images/*.img

## Build U-Boot
echo -e "\nCleaning: U-Boot..."
cd u-boot/
make -j8 CROSS_COMPILE=aarch64-linux-gnu- distclean

## Build Linux
echo -e "\nCleaning: Linux..."
cd ../linux/
make -j8 ARCH=arm64 distclean

echo -e "\nDone."
