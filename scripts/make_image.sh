#!/bin/bash

set -e -o pipefail

## Parameters
source config/config

## Board configuraions
source ${BOARD_CONFIG}/${KHADAS_BOARD}.conf

## Functions
source config/functions/functions

######################################################################################
prepare_host
if [ "$INSTALL_TYPE_RAW" == "yes" -a "$INSTALL_TYPE" == "EMMC" ]; then
	pack_image_platform_raw
else
	pack_image_platform
fi
compress_image

echo -e "\nDone."
echo -e "\n`date`"
