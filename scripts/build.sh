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

check_make_params
prepare_host
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
	updater-deb)
		build_updater_deb
		;;
	debs)
		build_uboot_deb
		build_linux_debs
		build_board_deb
		[ "$DISTRIB_TYPE" != "server" ] && build_desktop_deb
		build_gpu_deb
		[[ $(type -t build_common_deb) == function ]] && build_common_deb
		build_updater_deb
		[[ $(type -t build_deb_packages_platform) == function ]] && build_deb_packages_platform
		;;
esac

echo -e "\nDone."
echo -e "\n`date`"
