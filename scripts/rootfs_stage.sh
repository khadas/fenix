#!/bin/bash

set -e -o pipefail

## Parameters
source config/config

## Board configuraions
source ${BOARD_CONFIG}/${KHADAS_BOARD}.conf

## Functions
source config/functions/functions

######################################################################################

if [[ $EUID != 0 ]]; then
	need_sudo || true
	$sudo "$0" "$@"
	exit $?
fi

#clean_old_session
prepare_rootfs
[ "$CREATE_ROOTFS_CACHE_ONLY" == "yes" ] && post_create_image && exit

build_rootfs
if [ "$INSTALL_TYPE_RAW" == "yes" -a "$INSTALL_TYPE" == "EMMC" ]; then
	pack_image_platform_raw
else
	pack_image_platform
fi
compress_image
post_create_image
