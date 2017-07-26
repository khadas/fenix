#!/bin/bash

########################### Parameters ###################################

BASE_DIR="$HOME"
PROJECT_DIR="${BASE_DIR}/project"
KHADAS_DIR="${PROJECT_DIR}/khadas"
UBUNTU_WORKING_DIR="${KHADAS_DIR}/ubuntu"

CURRENT_FILE="$0"

ERROR="\033[31mError:\033[0m"
WARNING="\033[35mWarning:\033[0m"


cd ${UBUNTU_WORKING_DIR}
./utils/aml_image_v2_packer -r images/upgrade/package.conf images/upgrade/ images/update.img




