#!/bin/bash

########################### Parameters ###################################

AML_UPDATE_TOOL_CONFIG=

BASE_DIR="$HOME"
PROJECT_DIR="${BASE_DIR}/project"
KHADAS_DIR="${PROJECT_DIR}/khadas"
UBUNTU_WORKING_DIR="$(dirname "$(dirname "$(readlink -fm "$0")")")"
IMAGE_DIR="${UBUNTU_WORKING_DIR}/images/"
IMAGE_FILE_NAME="KHADAS_${KHADAS_BOARD}_${INSTALL_TYPE}.img"
IMAGE_FILE_NAME=$(echo $IMAGE_FILE_NAME | tr "[A-Z]" "[a-z]")

## Download packages directory
DOWNLOAD_PKG_DIR="$UBUNTU_WORKING_DIR/downloads"
## Packages directory
PKGS_DIR="$UBUNTU_WORKING_DIR/packages"
## Packages build directory
BUILD="$UBUNTU_WORKING_DIR/build"
## Build images
BUILD_IMAGES="$BUILD/images"
## Toolchains
TOOLCHAINS="$BUILD/toolchains"

UTILS_DIR="$BUILD/utils-[0-9a-f]*"

CURRENT_FILE="$0"

ERROR="\033[31mError:\033[0m"
WARNING="\033[35mWarning:\033[0m"

############################## Functions #################################
## Print error message
## $1 - file name
## $2 - line number
## $3 - message
error_msg() {
	echo -e "$1:$2" $ERROR "$3"
}

## Print warning message
## $1 - file name
## $2 - line number
## $3 - message
warning_msg() {
	echo -e "$1:$2" $WARNING "$3"
}

## $1 board              <VIM | VIM2>
## $2 install type       <EMMC | SD-USB>
check_parameters() {
	if [ "$1" == "" ]; then
		echo "usage: $0 <VIM|VIM2> <EMMC|SD-USB>"
		return -1;
	fi

	return 0
}

## Prepare amlogic usb updete tool configuration
prepare_aml_update_tool_config() {
	ret=0
	case "$KHADAS_BOARD" in
		VIM)
			AML_UPDATE_TOOL_CONFIG="package.conf"
			;;
		VIM2)
			AML_UPDATE_TOOL_CONFIG="package.conf"
			;;
		*)
			error_msg $CURRENT_FILE $LINENO "Unsupported board:$KHADAS_BOARD"
			AML_UPDATE_TOOL_CONFIG=
			ret=-1
			;;
	esac

	return $ret
}


## Pack the images
pack_update_image() {
	cd ${UBUNTU_WORKING_DIR}

	echo "Image install type: $INSTALL_TYPE"
	if [ "$INSTALL_TYPE" == "EMMC" ]; then
		if [ $AML_UPDATE_TOOL_CONFIG == "" ]; then
			error_msg $CURRENT_FILE $LINENO "'AML_UPDATE_TOOL_CONFIG' is empty!"
			return -1
		fi
		echo "Packing update image using config: $AML_UPDATE_TOOL_CONFIG"
		$UTILS_DIR/aml_image_v2_packer -r images/upgrade/$AML_UPDATE_TOOL_CONFIG images/upgrade/ images/${IMAGE_FILE_NAME}
	elif [ "$INSTALL_TYPE" == "SD-USB" ]; then

		IMAGE_LOOP_DEV="$(sudo losetup --show -f ${IMAGE_DIR}${IMAGE_FILE_NAME})"
		sudo partprobe "${IMAGE_LOOP_DEV}"

		if [ "$UBOOT" == "mainline" ]; then
			UBOOT_SD_BIN="$BUILD_IMAGES/u-boot-mainline/u-boot.bin.sd.bin"
		elif [ "$UBOOT" == "2015.01" ]; then
			UBOOT_SD_BIN="u-boot/fip/u-boot.bin.sd.bin"
		fi

		sudo dd if=$UBOOT_SD_BIN of="${IMAGE_LOOP_DEV}" conv=fsync bs=1 count=442
		sudo dd if=$UBOOT_SD_BIN of="${IMAGE_LOOP_DEV}" conv=fsync bs=512 skip=1 seek=1

		sudo losetup -d "${IMAGE_LOOP_DEV}"
	else
		error_msg $CURRENT_FILE $LINENO "Unsupported install type: '$INSTALL_TYPE'"
		return -1
	fi
}

##########################################################
check_parameters $@
prepare_aml_update_tool_config
pack_update_image

echo -e "\nDone."
echo -e "\n`date`"
