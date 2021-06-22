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
	update_git_repo "$PWD" ${FENIX_BRANCH:- master}
}

## Display parameters
display_parameters() {
	echo ""
	echo "***********************PARAMETERS************************"
	echo "Fenix Version:         $VERSION"

	if [ "$CREATE_ROOTFS_CACHE_ONLY" != "yes" ]; then
		echo "Khadas Board:          $KHADAS_BOARD"
		[ "$KHADAS_BOARD" != "Generic" ] && echo "Uboot Version:         $UBOOT"
		[ "$KHADAS_BOARD" != "Generic" ] && echo "Uboot Configuration:   $UBOOT_DEFCONFIG"
		[ "$KHADAS_BOARD" != "Generic" ] && echo "Uboot Branch:          $UBOOT_GIT_BRANCH"
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
		[ "$COMPRESS_IMAGE" == "yes" ] && \
		echo "Compressed Image:      $IMAGE_FILE_NAME.xz"
	else
		echo "Rootfs cache:          ${DISTRIB_RELEASE}-${DISTRIB_TYPE}-${DISTRIB_ARCH}.$(get_package_list_hash).tar.lz4"
	fi
	echo "*********************************************************"
	echo ""
}

## Build deb packages
build_debs() {

	info_msg "Building debs..."

	mkdir -p $BUILD_IMAGES

	# Build u-boot deb
	if [ "$KHADAS_BOARD" != "Generic" ]; then
		build_uboot_deb
	fi

	# Build linux debs
	if [ "$FORCE_BUILD_KERNEL_DEB" == "yes" ]; then
		info_msg "Force build kernel debian package..."
		build_linux_debs
	else
		if [[ ! -f $BUILD_DEBS/$VERSION/${LINUX_IMAGE_DEB}_${VERSION}_${DISTRIB_ARCH}.deb ]]; then
			build_linux_debs
		else
			# Debs exist, but kernel version changed
			LINUX_DEB_VER=$(dpkg --info $BUILD_DEBS/$VERSION/${LINUX_IMAGE_DEB}_${VERSION}_${DISTRIB_ARCH}.deb | grep Descr | awk '{print $(NF)}') #' coloring bug
			LINUX_VER=$(grep "Linux/arm64" $LINUX_DIR/.config | awk '{print $3}')
			if [ "$LINUX_DEB_VER" != "$LINUX_VER" ]; then
				build_linux_debs
			fi
		fi
	fi

	# Build GPU deb
	build_gpu_deb

	# Build board deb
	build_board_deb

	# Build updater deb
	build_updater_deb

	# Build desktop deb
	if [ "$DISTRIB_TYPE" != "server" ]; then
		build_desktop_deb
	fi

	# Build common deb packages
	if [[ $(type -t build_common_deb) == function ]]; then
		build_common_deb
	fi

	# Build deb packages platform
	if [[ $(type -t build_deb_packages_platform) == function ]]; then
		build_deb_packages_platform
	fi
}

###########################################################

start_time=`date +%s`
check_make_params
display_parameters

check_active_session
[ "$CHECK_BUSY" ] && \
check_busy_files "$BUILD"
# clean broken prev session
clean_old_session

prepare_host
check_update
prepare_toolchains
prepare_packages
[ "$CREATE_ROOTFS_CACHE_ONLY" == "yes" ] && info_msg "Creating rootfs cache only"
[ "$CREATE_ROOTFS_CACHE_ONLY" != "yes" ] && build_uboot
[ "$CREATE_ROOTFS_CACHE_ONLY" != "yes" ] && build_linux
[ "$CREATE_ROOTFS_CACHE_ONLY" != "yes" ] && build_debs

cd $ROOT

## Rootfs stage requires root privileges
need_sudo || true
$sudo $ROOT/scripts/rootfs_stage.sh

echo -e "\nDone."
echo -e "\n`date`"

end_time=`date +%s`

time_cal $(($end_time - $start_time))
