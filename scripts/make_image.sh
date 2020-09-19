#!/bin/bash

set -e -o pipefail

## Parameters
source config/config

## Board configuraions
source ${BOARD_CONFIG}/${KHADAS_BOARD}.conf

## Functions
source config/functions/functions

######################################################################################
check_make_params
prepare_host
pack_image_platform
compress_image

echo -e "\nDone."
echo -e "\n`date`"
