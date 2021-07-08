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

prepare_host
prepare_toolchains
prepare_packages

case "$TARGET" in
	u-boot)
		build_uboot
		;;
	u-boot-clean)
		clean_uboot
		;;
	linux)
		build_linux
		;;
	linux-clean)
		clean_linux
		;;
	linux-config)
		config_linux
		;;
	linux-saveconfig)
		save_linux_config
		;;
	uboot-deb)
		build_uboot_deb
		;;
	uboot-image)
		pack_image_platform "uboot-image"
		compress_image "uboot-image"
		;;
	linux-deb)
		unset build_linux_debs_
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
