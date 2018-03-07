#!/bin/bash

######################################################################
source config/config

cd $UBUNTU_WORKING_DIR

## images
echo -e "\nCleaning: images..."
rm -rf images/*.img

## Clean U-Boot
echo -e "\nCleaning: U-Boot..."
cd u-boot/
make -j8 CROSS_COMPILE=aarch64-linux-gnu- distclean

## Clean Linux
echo -e "\nCleaning: Linux..."
cd ../linux/
make -j8 ARCH=arm64 distclean

echo -e "\nDone."
echo -e "\n`date`"
