#!/bin/bash

set -e -o pipefail

## Parameters
source config/config

## Board configuraions
source ${BOARD_CONFIG}/${KHADAS_BOARD}.conf

## Functions
source config/functions/functions
#################################################################

cd $ROOT

## Cleanup build images
info_msg  "Cleanup build images..."
warning_msg "This script requires root privileges, trying to use sudo, please enter your passowrd!"
sudo rm -rf $BUILD
rm -rf $DOWNLOAD_PKG_DIR

## Cleanup U-Boot
info_msg "Cleanup U-Boot..."
cd $ROOT/u-boot
make -j8 CROSS_COMPILE=aarch64-linux-gnu- distclean

## Cleanup Linux
info_msg "Cleanup Linux..."
cd $ROOT/linux
make -j8 ARCH=arm64 distclean

echo -e "\nDone."
echo -e "\n`date`"
