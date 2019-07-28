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

prepare_toolchains
prepare_packages

case "$TARGET" in
	u-boot)
		build_uboot
		;;
	linux)
		build_linux
		;;
	uboot-deb)
		build_uboot_deb
		;;
	linux-deb)
		build_linux_debs
		;;
	board-deb)
		build_board_deb
		;;
	desktop-deb)
		build_desktop_deb
		;;
	gpu-deb)
		build_gpu_deb
		;;
	common-deb)
		build_common_deb
		;;
	debs)
		build_uboot_deb
		build_linux_debs
		build_board_deb
		build_desktop_deb
		build_gpu_deb
		build_common_deb
		;;
esac

echo -e "\nDone."
echo -e "\n`date`"
