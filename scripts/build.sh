#!/bin/bash

set -e -o pipefail

## Parameters
source config/config

## Board configuraions
source ${BOARD_CONFIG}/${KHADAS_BOARD}.conf

## Functions
source config/functions/functions

######################################################################################
TARGET="$1"

if [ "$TARGET" != "linux" ] && [ "$TARGET" != "linux-deb" ] && [ "$TARGET" != "u-boot" ]; then
	error_msg "Unsupported target: $TARGET"
	exit -1
fi

prepare_toolchains
prepare_packages

case "$TARGET" in
	linux)
		build_linux
		;;
	linux-deb)
		build_linux_debs
		build_board_deb
		build_desktop_deb
		build_gpu_deb
		;;
	u-boot)
		build_uboot
		;;
esac

echo -e "\nDone."
echo -e "\n`date`"
