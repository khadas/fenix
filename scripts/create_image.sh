#!/bin/bash

set -e -o pipefail

## Parameters
source config/config

## Board configuraions
source ${BOARD_CONFIG}/${KHADAS_BOARD}.conf

## Functions
source config/functions/functions

######################################################################################
## Try to update Fenix
check_update() {
	cd $ROOT

	update_git_repo "$PWD" "master"
}

## Display parameters
display_parameters() {
	echo ""
	echo "***********************PARAMETERS************************"
	echo "Fenix Version:         $VERSION"
	echo "Khadas Board:          $KHADAS_BOARD"
	echo "Uboot Version:         $UBOOT"
	echo "Uboot Configuration:   $UBOOT_DEFCONFIG"
	echo "Uboot Branch:          $UBOOT_GIT_BRANCH"
	echo "Linux Version:         $LINUX"
	echo "Linux Configuration:   $LINUX_DEFCONFIG"
	echo "Linux DTB:             $LINUX_DTB"
	echo "Linux Branch:          $LINUX_GIT_BRANCH"
	echo "Distribution:          $DISTRIBUTION"
	echo "Distribution Release:  $DISTRIB_RELEASE"
	echo "Distribution Type:     $DISTRIB_TYPE"
	echo "Distribution Arch:     $DISTRIB_ARCH"
	echo "Install Type:          $INSTALL_TYPE"
	echo "Final Image:           $IMAGE_FILE_NAME"
	echo "*********************************************************"
	echo ""
}

## Build deb packages
build_debs() {

	info_msg "Building debs..."

	mkdir -p $BUILD_IMAGES

	# Build linux debs
	if [[ ! -f $BUILD_DEBS/${LINUX_IMAGE_DEB}_${VERSION}_${DISTRIB_ARCH}.deb ]]; then
		build_linux_debs
	fi

	# Build GPU deb
	build_gpu_deb

	# Build board deb
	build_board_deb

	# Build desktop deb
	if [ "$DISTRIB_TYPE" != "server" ]; then
		build_desktop_deb
	fi

	# Build deb packages platform
	if [[ $(type -t build_deb_packages_platform) == function ]]; then
		build_deb_packages_platform
	fi
}

###########################################################
start_time=`date +%s`
display_parameters
prepare_host
check_update
prepare_toolchains
prepare_packages
build_uboot
build_linux
build_debs

cd $ROOT

## Rootfs stage requires root privileges
warning_msg "This script requires root privileges, trying to use sudo, please enter your passowrd!"
sudo -E $ROOT/scripts/rootfs_stage.sh

echo -e "\nDone."
echo -e "\n`date`"

end_time=`date +%s`

time_cal $(($end_time - $start_time))
