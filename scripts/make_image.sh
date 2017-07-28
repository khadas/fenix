#!/bin/bash

########################### Parameters ###################################

AML_UPDATE_TOOL_CONFIG=

BASE_DIR="$HOME"
PROJECT_DIR="${BASE_DIR}/project"
KHADAS_DIR="${PROJECT_DIR}/khadas"
UBUNTU_WORKING_DIR="$(dirname "$(dirname "$(readlink -fm "$0")")")"

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
check_parameters() {
	if [ "$1" == "" ]; then
		echo "usage: $0 <VIM|VIM2>"
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
			AML_UPDATE_TOOL_CONFIG="package_VIM2.conf"
			;;
		*)
			error_msg $CURRENT_FILE $LINENO "Unsupported board:$KHADAS_BOARD"
			AML_UPDATE_TOOL_CONFIG=
			ret=-1
			;;
	esac

	return $ret
}


## Pack the images to update.img
pack_update_image() {
	cd ${UBUNTU_WORKING_DIR}

	if [ $AML_UPDATE_TOOL_CONFIG == "" ]; then
		error_msg $CURRENT_FILE $LINENO "'AML_UPDATE_TOOL_CONFIG' is empty!"
		return -1
	fi

	echo "Packing update image using config: $AML_UPDATE_TOOL_CONFIG"
	./utils/aml_image_v2_packer -r images/upgrade/$AML_UPDATE_TOOL_CONFIG images/upgrade/ images/update.img
}

##########################################################
check_parameters $1               &&
prepare_aml_update_tool_config    &&
pack_update_image                 &&

echo -e "\nDone."
echo -e "\n`date`"
