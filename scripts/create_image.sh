#!/bin/bash

set -e -o pipefail

########################### Parameters ###################################

UBOOT_DEFCONFIG=
LINUX_DTB=
UBUNTU_ROOTFS=
UBOOT_GIT_BRANCH=
LINUX_GIT_BRANCH=
LINUX_DIR=

AML_UPDATE_TOOL_CONFIG=

UBUNTU_SERVER_IMAGE_SIZE=800 # MB
UBUNTU_MATE_IMAGE_SIZE=5000 # MB

UBUNTU_TYPE=$1

BASE_DIR="$HOME"
PROJECT_DIR="${BASE_DIR}/project"
KHADAS_DIR="${PROJECT_DIR}/khadas"
UBUNTU_WORKING_DIR="$(dirname "$(dirname "$(readlink -fm "$0")")")"
IMAGE_FILE_NAME="KHADAS_${KHADAS_BOARD}_${INSTALL_TYPE}.img"
IMAGE_FILE_NAME=$(echo $IMAGE_FILE_NAME | tr "[A-Z]" "[a-z]")
IMAGE_SIZE=


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
UPGRADE_DIR="$BUILD/images_upgrade-[0-9a-f]*"

CURRENT_FILE="$0"

ERROR="\033[31mError:\033[0m"
WARNING="\033[35mWarning:\033[0m"

trap cleanup INT EXIT TERM

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

## Calculate time
## $1 - time in seconds
time_cal() {
	local days hours minutes seconds temp

	second=$(($1 % 60))
	minute=$(($1 / 60))
	temp=$minute
	minute=$(($temp % 60))
	hour=$(($temp / 60))
	temp=$hour
	hour=$(($temp % 24))
	day=$(($temp / 24))

	echo "Time elapsed: $day days $hour hours $minute minutes $second seconds."
}

## $1 ubuntu type           <server | mate>
## $2 board              	<VIM | VIM2>
## $3 ubuntu version     	<16.04.2 | 17.04 | 17.10>
## $4 linux version      	<4.9 | 3.14 | mainline>
## $5 ubuntu architecture   <arm64 | armhf>
## $6 install type          <EMMC | SD-USB>
check_parameters() {
	if [ "$1" == "" ] || [ "$2" == "" ]  || [ "$3" == "" ] || [ "$4" == "" ] || [ "$5" == "" ] || [ "$6" == "" ]; then
		echo "usage: $0 <server|mate> <VIM|VIM2> <16.04.2|17.04|17.10> <4.9|3.14|mainline> <arm64|armhf> <EMMC|SD-USB>"
		return -1;
	fi

	return 0
}

## Umount
do_umount() {
	if mount | grep $1 > /dev/null; then
		sudo umount $1
	fi
}

## Cleanup
cleanup() {
	cd $UBUNTU_WORKING_DIR
	echo "Cleanup..."
	sync

	if mount | grep $PWD/rootfs > /dev/null; then
		do_umount "rootfs/dev/pts"
		do_umount "rootfs/dev"
		do_umount "rootfs/proc"
		do_umount "rootfs/sys/kernel/security"
		do_umount "rootfs/sys"
		do_umount "rootfs"
	fi

	if [ "$INSTALL_TYPE" == "SD-USB" ]; then
		if mount | grep $PWD/boot > /dev/null; then
			do_umount "boot"
			sudo losetup -d "${IMAGE_LOOP_DEV}"
		fi
	fi
}

unset_package_vars() {
	unset PKG_NAME
	unset PKG_VERSION
	unset PKG_VERSION_SHORT
	unset PKG_REV
	unset PKG_ARCH
	unset PKG_LICENSE
	unset PKG_SITE
	unset PKG_URL
	unset PKG_SOURCE_DIR
	unset PKG_SOURCE_NAME
	unset PKG_NEED_BUILD
	unset PKG_SHA256
}

## Download package
## S1 package
download_package() {

	local PKG="$1"
	local STAMP_URL
	local STAMP_SHA
	local WGET_CMD

	mkdir -p $DOWNLOAD_PKG_DIR/$PKG
	cd $DOWNLOAD_PKG_DIR/$PKG

	unset_package_vars
	if [ -f "$PKGS_DIR/$PKG/package.mk" ]; then
		. $PKGS_DIR/$PKG/package.mk
		if [ "$PKG_NAME" != "$PKG" ]; then
			error_msg $CURRENT_FILE $LINENO "Package name mismatch! '$PKG_NAME' != '$PKG'"
			return -1
		fi
	else
		error_msg $CURRENT_FILE $LINENO "Package '$PKG' doesn't exist!"
		return -1
	fi

	STAMP_URL="$PKG_SOURCE_NAME.url"
	STAMP_SHA="$PKG_SOURCE_NAME.sha256"
	WGET_CMD="wget --timeout=30 --tries=3 --passive-ftp --no-check-certificate -O $PKG_SOURCE_NAME"

	# Check
	if [ -f $PKG_SOURCE_NAME ]; then
		if [ "$(cat $STAMP_URL 2>/dev/null)" == "${PKG_URL}" ]; then
			[ -z "${PKG_SHA256}" -o "$(cat $STAMP_SHA 2>/dev/null)" == "${PKG_SHA256}" ] && return 0
		fi
	fi

	rm -f $STAMP_URL $STAMP_SHA

	# Download
	local NBWGET=10
	while [ $NBWGET -gt 0 ]; do
		rm -rf $PKG_SOURCE_NAME

		if $WGET_CMD "$PKG_URL"; then
			CALC_SHA256="$(sha256sum $PKG_SOURCE_NAME | cut -d" " -f1)"
			[ -z "${PKG_SHA256}" -o "${PKG_SHA256}" == "${CALC_SHA256}" ] && break

			error_msg $CURRENT_FILE $LINENO "Incorrect checksum calculated on downloaded file: got ${CALC_SHA256}, wanted ${PKG_SHA256}"
		fi
		NBWGET=$((NBWGET - 1))
	done

	if [ $NBWGET -eq 0 ]; then
		error_msg $CURRENT_FILE $LINENO "Cant't get $PKG_NAME sources : $PKG_URL\n Try later !!"
		return -1
	else
		echo "Calculated checksum is: ${CALC_SHA256}"
		echo "${PKG_URL}" > $STAMP_URL
		echo "${CALC_SHA256}" > $STAMP_SHA
	fi
}

## Extract package
## $1 package
## $2 target dir
extract_package() {
	if [ -z "$2" ]; then
		echo "usage: $0 package_name target_dir"
		return -1
	fi

	[ -z "$PKG_URL" -o -z "$PKG_SOURCE_NAME" ] && return -1
	[ ! -d "$DOWNLOAD_PKG_DIR/$1" -o ! -d "$2" ] && return -1

	echo "Extracting '$PKG_SOURCE_NAME' to '$2'..."

	for pattern in .tar.gz .tar.xz .tar.bz2 .tgz .txz .tbz .7z .zip; do
		if [[ $PKG_SOURCE_NAME =~ ${pattern//./\\.}$ ]]; then
			f="$DOWNLOAD_PKG_DIR/$1/$PKG_SOURCE_NAME"
			if [ ! -f $f ]; then
				error_msg $CURRENT_FILE $LINENO "error: File $PKG_SOURCE_NAME doesn't exist in package $1 downloads directory"
				return -1
			fi
			case $PKG_SOURCE_NAME in
				*.tar)
					tar xf $f -C $2
					;;
				*.tar.bz2 | *.tbz)
					tar xjf $f -C $2
					;;
				*.tar.gz | *.tgz)
					tar xzf $f -C $2
					;;
				*.tar.xz | *.txz)
					tar xJf $f -C $2
					;;
				*.7z)
					mkdir -p $2/$1
					7z x -o$2/$1 $f
					;;
				*.zip)
					unzip -q $f -d $2
					;;
				*.diff | *.patch)
					cat $f | patch -d $2 -p1
					;;
				*.diff.bz2 | *.patch.bz2 | patch-*.bz2)
					bzcat $f | patch -d $2 -p1
					;;
				*.diff.gz | *.patch.gz | patch-*.gz)
					zcat $f | patch -d $2 -p1
					;;
				*)
					cp -pPR $f $2
					;;
			esac
			break
		fi
	done
}

## Clean package
## $1 pakage
clean_package() {

	for i in $BUILD/$1-*; do
		if [ -d $i -a -f "$i/.fenix-unpack" ] ; then
			. "$i/.fenix-unpack"
			if [ "$STAMP_PKG_NAME" = "$1" ]; then
				printf "%${BUILD_INDENT}c ${boldred}*${endcolor} ${red}Removing $i ...${endcolor}\n" ' '
				rm -rf $i
			fi
		else
			# force clean if no stamp found (previous unpack failed)
			printf "%${BUILD_INDENT}c * Removing $i ...\n" ' '
			rm -rf $i
		fi
	done


	return 0
}

## Unpack package
## $1 package name
unpack_package() {

	local PKG="$1"
	local STAMP
	local STAMP_DEPENDS
	local PKG_BUILD
	local PKG_DIR

	download_package "$PKG"

	mkdir -p $BUILD

	PKG_DIR="$PKGS_DIR/$PKG"
	PKG_BUILD="$BUILD/${PKG_NAME}-${PKG_VERSION}"
	STAMP=$PKG_BUILD/.fenix-unpack
	STAMP_DEPENDS="$PKG_DIR"

	local PKG_DEEPMD5=
	for i in $BUILD/$PKG-*; do
		if [ -d $i -a -f "$i/.fenix-unpack" ] ; then
			. "$i/.fenix-unpack"
			if [ "$STAMP_PKG_NAME" = "$PKG" ]; then
				[ -z "${PKG_DEEPMD5}" ] && PKG_DEEPMD5=$(find $STAMP_DEPENDS -exec md5sum {} \; 2>/dev/null | sort | md5sum | cut -d" " -f1)
				if [ ! "$PKG_DEEPMD5" = "$STAMP_PKG_DEEPMD5" ] ; then
					clean_package $PKG
				fi
			fi
		fi
	done

	if [ -d "$PKG_BUILD" -a ! -f "$STAMP" ]; then
		clean_package $PKG
	fi

	[ -f "$STAMP" ] && return 0

	if [ -d "$DOWNLOAD_PKG_DIR/$PKG" ]; then
		# unset functions
		unset -f pre_unpack
		unset -f unpack
		unset -f post_unpack
		unset -f pre_patch
		unset -f post_patch

		. $PKGS_DIR/$PKG/package.mk

		if [ "$(type -t pre_unpack)" = "function" ]; then
			pre_unpack
		fi

		if [ "$(type -t unpack)" = "function" ]; then
			unpack
		else
			if [ -n "$PKG_URL" ]; then
				extract_package $PKG $BUILD
			fi
		fi

		if [ ! -d $BUILD/$PKG_NAME-$PKG_VERSION ]; then
			if [ -n "$PKG_SOURCE_DIR" ]; then
				mv $BUILD/$PKG_SOURCE_DIR $BUILD/$PKG_NAME-$PKG_VERSION
			elif [ -d $BUILD/$PKG_NAME-$PKG_VERSION* ]; then
				mv $BUILD/$PKG_NAME-$PKG_VERSION* $BUILD/$PKG_NAME-$PKG_VERSION
			fi
		fi

		if [ -d "$PKG_DIR/sources" ]; then
			[ ! -d "$BUILD/${PKG_NAME}-${PKG_VERSION}" ] && mkdir -p $BUILD/${PKG_NAME}-${PKG_VERSION}
			cp -PRf $PKG_DIR/sources/* $BUILD/${PKG_NAME}-${PKG_VERSION}
		fi

		if [ "$(type -t post_unpack)" = "function" ]; then
			post_unpack
		fi

		if [ "$(type -t pre_patch)" = "function" ]; then
			pre_patch
		fi

		for i in $PKG_DIR/patches/$PKG_NAME-*.patch \
				 $PKG_DIR/patches/$PKG_VERSION/*.patch; do

			if [ -f "$i" ]; then
				if [ -n "$(grep -E '^GIT binary patch$' $i)" ]; then
					cat $i | git apply --directory=`echo "$PKG_BUILD" | cut -f1 -d\ ` -p1 --verbose --whitespace=nowarn --unsafe-paths
				else
					cat $i | patch -d `echo "$PKG_BUILD" | cut -f1 -d\ ` -p1
				fi
			fi
		done

		if [ "$(type -t post_patch)" = "function" ]; then
			post_patch
		fi

		PKG_DEEPMD5=$(find $STAMP_DEPENDS -exec md5sum {} \; 2>/dev/null | sort | md5sum | cut -d" " -f1)
		for i in PKG_NAME PKG_DEEPMD5; do
			echo "STAMP_$i=\"${!i}\"" >> $STAMP
		done
	fi

	return 0
}

## Build package
## $1 package
build_package() {

	if [ -z "$1" ]; then
		echo "usage: $0 package_name"
		return -1
	fi

	local STAMPS
	local PKG_DIR
	local PKG_BUILD
	local STAMP_DEPENDS
	local PACKAGE_NAME
	local TARGET

	PACKAGE_NAME=$(echo $1 | awk -F : '{print $1}')
	TARGET=$(echo $1 | awk -F : '{print $2}')
	if [ -z "$TARGET" ]; then
		TARGET="target"
	fi

	if [ ! -f $PKGS_DIR/$PACKAGE_NAME/package.mk ]; then
		error_msg $CURRENT_FILE $LINENO "$1: no package.mk file found!"
		return -1
	fi


	unpack_package $PACKAGE_NAME

	STAMPS=$BUILD/.stamps
	PKG_DIR="$PKGS_DIR/$PACKAGE_NAME"
	PKG_BUILD="$BUILD/${PKG_NAME}-${PKG_VERSION}"

	mkdir -p $STAMPS/$PKG_NAME
	STAMP=$STAMPS/$PKG_NAME/build_$TARGET

	STAMP_DEPENDS="$PKG_DIR"

	if [ -f $STAMP ] ; then
		. $STAMP
		PKG_DEEPMD5=$(find $STAMP_DEPENDS -exec md5sum {} \; 2>/dev/null | sort | md5sum | cut -d" " -f1)
		if [ ! "$PKG_DEEPMD5" = "$STAMP_PKG_DEEPMD5" ] ; then
			rm -f $STAMP
		fi
	fi

	if [ ! -f $STAMP ]; then
		# unset functions
		unset -f pre_build_target
		unset -f pre_make_target
		unset -f make_target
		unset -f post_make_target
		unset -f makeinstall_target

		unset -f pre_build_host
		unset -f pre_make_host
		unset -f make_host
		unset -f post_make_host
		unset -f makeinstall_host

		. $PKG_DIR/package.mk


		if [ "$(type -t pre_build_$TARGET)" = "function" ]; then
			pre_build_$TARGET
		fi

		if [ ! -d $PKG_BUILD ] ; then
			mkdir -p $PKG_BUILD
		fi

		cd $PKG_BUILD

		if [ "$(type -t pre_make_$TARGET)" = "function" ]; then
			pre_make_$TARGET
		fi

		if [ "$(type -t make_$TARGET)" = "function" ]; then
			make_$TARGET
		fi

		if [ "$(type -t post_make_$TARGET)" = "function" ]; then
			post_make_$TARGET
		fi

		if [ "$(type -t makeinstall_$TARGET)" = "function" ]; then
			makeinstall_$TARGET
		fi

		PKG_DEEPMD5=$(find $STAMP_DEPENDS -exec md5sum {} \; 2>/dev/null | sort | md5sum | cut -d" " -f1)
		for i in PKG_NAME PKG_DEEPMD5; do
			echo "STAMP_$i=\"${!i}\"" >> $STAMP
		done
	fi
}

## Prepare toolhains
prepare_toolchains() {

	build_package "gcc-linaro-aarch64-linux-gnu:host"
	build_package "gcc-linaro-aarch64-none-elf:host"
	build_package "gcc-linaro-arm-none-eabi:host"
	if [ "$UBOOT" == "mainline" ]; then
		build_package "gcc-linaro-aarch64-elf:host"
	fi

	return 0
}

## Prepare packages
prepare_packages() {
	if [ "$UBOOT" == "mainline" ]; then
		build_package "u-boot-mainline:target"
	fi

	if [ "$LINUX" == "mainline" ]; then
		build_package "linux-mainline:target"
	fi

	build_package "utils:host"
	build_package "images_upgrade:host"
}

## Select uboot configuration
prepare_uboot_configuration() {
	ret=0
	case "$KHADAS_BOARD" in
		VIM)
			UBOOT_DEFCONFIG="kvim_defconfig"
			;;
		VIM2)
			UBOOT_DEFCONFIG="kvim2_defconfig"
			;;
		*)
			error_msg $CURRENT_FILE $LINENO "Unsupported board:$KHADAS_BOARD"
			UBOOT_DEFCONFIG=
			ret=-1
	esac

	return $ret
}

## Select linux dtb
prepare_linux_dtb() {
	ret=0
	case "$KHADAS_BOARD" in
		VIM)
			if [ "$LINUX" == "mainline" ]; then
				LINUX_DTB="meson-gxl-s905x-khadas-vim.dtb"
			else
				LINUX_DTB="kvim_linux.dtb"
			fi
			;;
		VIM2)
			LINUX_DTB="kvim2_linux.dtb"
			;;
		*)
			error_msg $CURRENT_FILE $LINENO "Unsupported board:$KHADAS_BOARD"
			LINUX_DTB=
			ret=-1
			;;
	esac

	return $ret
}

prepare_git_branch() {
	ret=0
	case "$KHADAS_BOARD" in
		VIM)
			UBOOT_GIT_BRANCH="ubuntu"
			;;
		VIM2)
			UBOOT_GIT_BRANCH="ubuntu"
			;;
		*)
			error_msg $CURRENT_FILE $LINENO "Unsupported board:$KHADAS_BOARD"
			UBOOT_GIT_BRANCH=
			ret=-1
			;;
	esac

	case "$LINUX" in
		3.14)
			LINUX_GIT_BRANCH="ubuntu"
			;;
		4.9)
			LINUX_GIT_BRANCH="ubuntu-4.9"
			;;
	mainline)
			LINUX_GIT_BRANCH="master"
			;;
		*)
			error_msg $CURRENT_FILE $LINENO "Unsupported linux version:$LINUX"
			LINUX_GIT_BRANCH=
			ret=-1
	esac

	return $ret
}

## Fixup upgrade dtb link
fixup_dtb_link() {
	ret=0
	cd $UPGRADE_DIR
	rm -rf kvim.dtb

	case "$LINUX" in
		4.9)
			ln -s ../../linux/arch/arm64/boot/dts/amlogic/$LINUX_DTB kvim.dtb
			;;
		3.14)
			ln -s ../../linux/arch/arm64/boot/dts/$LINUX_DTB kvim.dtb
			;;
	mainline)
			;;
		*)
			error_msg $CURRENT_FILE $LINENO "Unsupported linux version:$LINUX"
			ret=-1
	esac

	cd -

	return $ret
}

## Select ubuntu rootfs
prepare_ubuntu_rootfs() {
	ret=0

	if [ "$UBUNTU_ARCH" != "arm64" ] && [ "$UBUNTU_ARCH" != "armhf" ]; then
		error_msg $CURRENT_FILE $LINENO "Unsupported ubuntu architecture: $UBUNTU_ARCH"
		return -1
	fi

	if [ "$UBUNTU_TYPE" == "server" ] || [ "$UBUNTU_MATE_ROOTFS_TYPE" == "chroot-install" ]; then
		UBUNTU_ROOTFS="ubuntu-base-$UBUNTU-base-$UBUNTU_ARCH.tar.gz"
	elif [ "$UBUNTU_TYPE" == "mate" ]; then
		if [ "$UBUNTU" == "16.04.2" ]; then
			UBUNTU_ROOTFS="ubuntu-mate-$UBUNTU-$UBUNTU_ARCH.tar.gz"
		else
			error_msg $CURRENT_FILE $LINENO "Unsupported ubuntu version:$UBUNTU_TYPE $UBUNTU for $UBUNTU_MATE_ROOTFS_TYPE"
			UBUNTU_ROOTFS=
			ret=-1
		fi
	else
		error_msg $CURRENT_FILE $LINENO "Unsupported ubuntu image type:$UBUNTU_TYPE"
		return -1
	fi

	return $ret
}

## Display parameters
display_parameters() {
	echo ""
	echo "***********************PARAMETERS************************"
	echo "board:                         $KHADAS_BOARD"
	echo "linux version:                 $LINUX"
	echo "uboot version:                 $UBOOT"
	echo "ubuntu type:                   $UBUNTU_TYPE"
	if [ "$UBUNTU_TYPE" == "mate" ]; then
		echo "ubuntu mate rootfs type:       $UBUNTU_MATE_ROOTFS_TYPE"
	fi
	echo "ubuntu version:                $UBUNTU"
	echo "ubuntu architecture:           $UBUNTU_ARCH"
	echo "install type:                  $INSTALL_TYPE"
	echo "uboot configuration:           $UBOOT_DEFCONFIG"
	echo "linux dtb:                     $LINUX_DTB"
	echo "ubuntu rootfs:                 $UBUNTU_ROOTFS"
	echo "uboot git branch:              $UBOOT_GIT_BRANCH"
	echo "linux git branch:              $LINUX_GIT_BRANCH"
	echo "base directory:                $BASE_DIR"
	echo "project directory:             $PROJECT_DIR"
	echo "khadas directory:              $KHADAS_DIR"
	echo "ubuntu working directory:      $UBUNTU_WORKING_DIR"
	echo "amlogic update tool config:    $AML_UPDATE_TOOL_CONFIG"
	echo "image directory:               $BUILD_IMAGES"
	echo "image file name:               $IMAGE_FILE_NAME"
	echo "*********************************************************"
	echo ""
}

## Prepare working environment
prepare_working_environment() {
#	install -d ${UBUNTU_WORKING_DIR}
#
#	if [ ! -d "ubuntu/.git" ]; then
#		##Clone fenix.git from Khadas GitHub
#		echo "Fenix repository dose not exist, clone fenix repository('master') from Khadas GitHub..."
#		git clone https://github.com/khadas/fenix.git ubuntu
#		[ $? != 0 ] && error_msg $CURRENT_FILE $LINENO "Failed to clone 'fenix.git'" && return -1
#	fi

	install -d ${UBUNTU_WORKING_DIR}/{linux,boot,rootfs,archives/{ubuntu-base,debs,hwpacks,ubuntu-mate},scripts}

	cd ${UBUNTU_WORKING_DIR}

	if [ "$LINUX" == "mainline" ]; then
		LINUX_DIR="$BUILD/linux-mainline-*"
	else
		LINUX_DIR="$UBUNTU_WORKING_DIR/linux"
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

## Build U-Boot
build_uboot() {
	ret=0

	if [ "$UBOOT" == "mainline" ]; then
		return 0
	fi

	if [ "$UBOOT_GIT_BRANCH" == "" ]; then
		error_msg $CURRENT_FILE $LINENO "'UBOOT_GIT_BRANCH' is empty!"
		return -1
	fi

	cd ${UBUNTU_WORKING_DIR}
	if [ ! -d u-boot/.git ]; then
		echo "U-boot repository does not exist, clone u-boot repository('$UBOOT_GIT_BRANCH') form Khadas GitHub..."
		## Clone u-boot from Khadas GitHub
		git clone https://github.com/khadas/u-boot -b $UBOOT_GIT_BRANCH
		[ $? != 0 ] && error_msg $CURRENT_FILE $LINENO "Failed to clone 'u-boot'" && return -1
	fi

	cd u-boot/

	if ! git branch | grep "^* $UBOOT_GIT_BRANCH$" > /dev/null; then
		echo "U-boot: Switch to branch '$UBOOT_GIT_BRANCH'"
		make distclean
		git checkout $UBOOT_GIT_BRANCH
		[ $? != 0 ] && error_msg $CURRENT_FILE $LINENO "U-boot: Switch to branch '$UBOOT_GIT_BRANCH' failed." && return -1
	else
		echo "U-boot: Already on branch '$UBOOT_GIT_BRANCH'"
	fi

	echo "Build u-boot..."
	export PATH=$TOOLCHAINS/gcc-linaro-aarch64-none-elf/bin:$TOOLCHAINS/gcc-linaro-arm-none-eabi/bin:$PATH
	make $UBOOT_DEFCONFIG
	make -j8 CROSS_COMPILE=aarch64-none-elf-
	ret=$?

	return $ret
}

## Build Linux
build_linux() {
	ret=0

	if [ "$LINUX" == "mainline" ]; then
		return 0
	fi

	if [ "$LINUX_GIT_BRANCH" == "" ] || [ "$LINUX_DTB" == "" ]; then
		[ "$LINUX_GIT_BRANCH" == "" ] && error_msg $CURRENT_FILE $LINENO "'LINUX_GIT_BRANCH' is empty!"
		[ "$LINUX_DTB" == "" ] && error_msg $CURRENT_FILE $LINENO "'LINUX_DTB' is empty!"
		return -1
	fi

	cd ${UBUNTU_WORKING_DIR}
	if [ ! -d linux/.git ]; then
		echo "Linux repository does not exist, clone linux repository('$LINUX_GIT_BRANCH') form Khadas GitHub..."
		## Clone linux from Khadas GitHub
		git clone https://github.com/khadas/linux -b $LINUX_GIT_BRANCH
		[ $? != 0 ] && error_msg $CURRENT_FILE $LINENO "Failed to clone 'linux'" && return -1
	fi

	cd linux/
	touch .scmversion

	if ! git branch | grep "^* $LINUX_GIT_BRANCH$" > /dev/null; then
		echo "Linux: Switch to branch '$LINUX_GIT_BRANCH'"
		make ARCH=arm64 distclean
		git checkout $LINUX_GIT_BRANCH
		[ $? != 0 ] && error_msg $CURRENT_FILE $LINENO "Linux: Switch to branch '$LINUX_GIT_BRANCH' failed." && return -1
	else
		echo "Linux: Already on branch '$LINUX_GIT_BRANCH'"
	fi

	echo "Build linux..."
	export PATH=$TOOLCHAINS/gcc-linaro-aarch64-linux-gnu/bin:$PATH
	make ARCH=arm64 kvim_defconfig
	make -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image dtbs  modules
}

## Setup ubuntu rootfs
setup_ubuntu_rootfs() {
	ret=0
	if [ "$UBUNTU_ROOTFS" == "" ]; then
		error_msg $CURRENT_FILE $LINENO "'UBUNTU_ROOTFS' is empty!"
		return -1
	fi

	if [ "$UBUNTU_TYPE" == "server" ]; then
		IMAGE_SIZE=$UBUNTU_SERVER_IMAGE_SIZE
		cd ${UBUNTU_WORKING_DIR}/archives/ubuntu-base
	elif [ "$UBUNTU_TYPE" == "mate" ]; then
		IMAGE_SIZE=$UBUNTU_MATE_IMAGE_SIZE
		if [ "$UBUNTU_MATE_ROOTFS_TYPE" == "mate-rootfs" ]; then
			if [ "$UBUNTU" == "16.04.2" ]; then
				cd ${UBUNTU_WORKING_DIR}/archives/ubuntu-mate
			else
				error_msg $CURRENT_FILE $LINENO "Ubuntu mate $UBUNTU is not supported to build use ubuntu mate rootfs now!" && return -1
			fi
		elif [ "$UBUNTU_MATE_ROOTFS_TYPE" == "chroot-install" ]; then
			cd ${UBUNTU_WORKING_DIR}/archives/ubuntu-base
		fi
	fi

	if [ ! -f $UBUNTU_ROOTFS ]; then
		if [ "$UBUNTU_TYPE" == "server" ] || [ "$UBUNTU_MATE_ROOTFS_TYPE" == "chroot-install" ]; then
			echo "'$UBUNTU_ROOTFS' does not exist, begin to downloading..."
			wget http://cdimage.ubuntu.com/ubuntu-base/releases/$UBUNTU/release/$UBUNTU_ROOTFS
		elif [ "$UBUNTU_TYPE" == "mate" ]; then
			if [ "$UBUNTU" == "16.04.2" ]; then
				## FIXME
				error_msg $CURRENT_FILE $LINENO "'$UBUNTU_ROOTFS' does not exist, please download it into folder '`pwd`' manually, and try again! Yon can refer to 'http://www.mediafire.com/file/sthi6u5gf7vxymz/ubuntu-mate-16.04.2-arm64.tar.gz' for ubuntu mate 16.04.2 rootfs." && ret=-1
			else
				error_msg $CURRENT_FILE $LINENO "Ubuntu mate $UBUNTU is not supported to build use ubuntu mate rootfs now!" && ret=-1
			fi
		fi

		[ $? != 0 ] && error_msg $CURRENT_FILE $LINENO "Failed to download '$UBUNTU_ROOTFS'" && ret=-1
	fi

	cd -

	return $ret
}

install_mali_driver() {

	if [ "$KHADAS_BOARD" == "VIM" ] && [ "$LINUX" != "mainline" ]; then
		GPU_VER="r5p1"

		cd $UBUNTU_WORKING_DIR

		# GPU user space binary drivers
		## Headers
		sudo cp -arf archives/hwpacks/mali/r7p0/include/EGL rootfs/usr/include/
		sudo cp -arf archives/hwpacks/mali/r7p0/include/GLES rootfs/usr/include/
		sudo cp -arf archives/hwpacks/mali/r7p0/include/GLES2 rootfs/usr/include/
		sudo cp -arf archives/hwpacks/mali/r7p0/include/KHR rootfs/usr/include/

		### fbdev
		sudo cp -arf archives/hwpacks/mali/r7p0/include/EGL_platform/platform_fbdev/*.h rootfs/usr/include/EGL/

		### wayland
		### sudo cp -arf archives/hwpacks/mali/r7p0/include/EGL_platform/platform_wayland/*.h rootfs/usr/include/EGL/
		## libMali.so
		### fbdev
		if [ "$UBUNTU_ARCH" == "arm64" ]; then
			sudo cp -arf archives/hwpacks/mali/r7p0/lib/arm64/$GPU_VER/m450/*.so* rootfs/usr/lib/
			sudo cp -arf archives/hwpacks/mali/r7p0/lib/arm64/$GPU_VER/m450/*.so* rootfs/usr/lib/aarch64-linux-gnu
		elif [ "$UBUNTU_ARCH" == "armhf" ]; then
			sudo cp -arf archives/hwpacks/mali/r7p0/lib/eabihf/$GPU_VER/m450/*.so* rootfs/usr/lib/
			sudo cp -arf archives/hwpacks/mali/r7p0/lib/eabihf/$GPU_VER/m450/*.so* rootfs/usr/lib/arm-linux-gnueabihf
		fi

		### wayland
		### if [ "$UBUNTU_ARCH" == "arm64" ]; then
		###     sudo cp -arf archives/hwpacks/mali/r7p0/lib/arm64/r7p0/m450/wayland/*.so* rootfs/usr/lib/
		###     sudo cp -arf archives/hwpacks/mali/r7p0/lib/arm64/r7p0/m450/wayland/*.so* rootfs/usr/lib/aarch64-linux-gnu
		###elif [ "$UBUNTU_ARCH" == "armhf" ]; then
		###     sudo cp -arf archives/hwpacks/mali/r7p0/lib/eabihf/r7p0/m450/wayland/*.so* rootfs/usr/lib/
		###     sudo cp -arf archives/hwpacks/mali/r7p0/lib/eabihf/r7p0/m450/wayland/*.so* rootfs/usr/lib/arm-linux-gnueabihf
		### fi

		### links
		sudo cp -arf archives/hwpacks/mali/r7p0/lib/*.so* rootfs/usr/lib/
		if [ "$UBUNTU_ARCH" == "arm64" ]; then
			sudo cp -arf archives/hwpacks/mali/r7p0/lib/*.so* rootfs/usr/lib/aarch64-linux-gnu
		elif [ "$UBUNTU_ARCH" == "armhf" ]; then
			sudo cp -arf archives/hwpacks/mali/r7p0/lib/*.so* rootfs/usr/lib/arm-linux-gnueabihf
		fi
			sudo mkdir -p rootfs/usr/lib/pkgconfig/
			sudo cp -arf archives/hwpacks/mali/r7p0/lib/pkgconfig/*.pc rootfs/usr/lib/pkgconfig/
		# Mali m450 framebuffer mode examples
		if [ "$UBUNTU_ARCH" == "arm64" ]; then
			sudo mkdir -p rootfs/usr/share/arm/
			sudo cp -arf archives/hwpacks/mali/fbdev_examples/$LINUX/lib/* rootfs/usr/lib/
			sudo cp -arf archives/hwpacks/mali/fbdev_examples/$LINUX/opengles_20 rootfs/usr/share/arm/
		fi

		sudo mkdir -p rootfs/usr/lib/udev/rules.d
		sudo cp -arf archives/filesystem/usr/lib/udev/rules.d/* rootfs/usr/lib/udev/rules.d

	elif [ "$KHADAS_BOARD" == "VIM" ] && [ "$LINUX" == "mainline" ] && [ "$UBUNTU_TYPE" == "mate" ] && [ "$UBUNTU_ARCH" == "arm64" ]; then
		# VIM mainline X11 mali driver
		## install mali.ko
		build_package "meson-gx-mali-450:target"
		VER=$(ls $UBUNTU_WORKING_DIR/rootfs/lib/modules/)
		sudo cp $BUILD/meson-gx-mali-450-*/mali.ko $UBUNTU_WORKING_DIR/rootfs/lib/modules/$VER/kernel/
		sudo depmod -b $UBUNTU_WORKING_DIR/rootfs/ -a $VER
		## libMali X11
		cd $UBUNTU_WORKING_DIR
		sudo mkdir -p rootfs/usr/lib/mali
		sudo cp archives/hwpacks/mali/r7p0/lib/arm64/r7p0/m450-X/libMali.so rootfs/usr/lib/mali/
		cd rootfs/usr/lib/mali
		sudo ln -s libMali.so libGLESv2.so.2.0
		sudo ln -s libMali.so libGLESv1_CM.so.1.1
		sudo ln -s libMali.so libEGL.so.1.4
		sudo ln -s libGLESv2.so.2.0 libGLESv2.so.2
		sudo ln -s libGLESv1_CM.so.1.1 libGLESv1_CM.so.1
		sudo ln -s libEGL.so.1.4 libEGL.so.1
		sudo ln -s libGLESv2.so.2 libGLESv2.so
		sudo ln -s libGLESv1_CM.so.1 libGLESv1_CM.so
		sudo ln -s libEGL.so.1 libEGL.so
		cd -
		sudo cp -ar archives/hwpacks/mali/r7p0/include/* rootfs/usr/include/
		sudo tee "rootfs/etc/ld.so.conf.d/mali.conf" <<-EOF
		/usr/lib/mali
		EOF
		build_package "xf86-video-armsoc:target"
		sudo cp -r $BUILD/xf86-video-armsoc-* $UBUNTU_WORKING_DIR/rootfs/xf86-video-armsoc

		cd $UBUNTU_WORKING_DIR
	fi
}

## Install kodi
install_kodi() {
	if [ "$KHADAS_BOARD" == "VIM" ] && [ "$LINUX" == "3.14" ] && [ "$UBUNTU_TYPE" == "mate" ]; then
		build_package "pkg-aml-kodi:target"
		build_package "pkg-aml-codec:target"
		build_package "pkg-aml-amremote:target"

		cd $UBUNTU_WORKING_DIR
		sudo cp $BUILD_IMAGES/pkg-aml-kodi/*.deb rootfs/pkg-aml-kodi_${UBUNTU_ARCH}.deb
		sudo cp $BUILD_IMAGES/pkg-aml-codec/*.deb rootfs/pkg-aml-codec_${UBUNTU_ARCH}.deb
		sudo cp $BUILD_IMAGES/pkg-aml-amremote/*.deb rootfs/pkg-aml-amremote_${UBUNTU_ARCH}.deb
	fi
}

# Arguments:
#   $1 - kernel version
#   $2 - kernel image file
#   $3 - kernel map file
#   $4 - default install path (blank if root directory)
install_kernel() {
	if [ "$(basename $2)" = "Image.gz" ]; then
		# Compressed install
		echo "Installing compressed kernel"
		base=vmlinuz
	else
		# Normal install
		echo "Installing normal kernel"
		base=vmlinux
	fi

	if [ -f $4/$base-$1 ]; then
		sudo mv $4/$base-$1 $4/$base-$1.old
	fi
	sudo cp $2 $4/$base-$1

	# Install system map file
	if [ -f $4/System.map-$1 ]; then
		sudo mv $4/System.map-$1 $4/System.map-$1.old
	fi
	sudo cp $3 $4/System.map-$1

	# Install config file
	config=$(dirname "$3")
	config="${config}/.config"
	if [ -f $4/config-$1 ]; then
		sudo mv $4/config-$1 $4/config-$1.old
	fi
	sudo cp $config $4/config-$1
}

## Rootfs
build_rootfs() {
	ret=0
	cd ${UBUNTU_WORKING_DIR}

	IMAGE_LINUX_LOADADDR="0x1080000"
	IMAGE_LINUX_VERSION=`head -n 1 $LINUX_DIR/include/config/kernel.release | xargs echo -n`
	BOOT_DIR=

	mkdir -p $BUILD_IMAGES

	if [ "$INSTALL_TYPE" == "EMMC" ]; then
		BOOT_DIR="rootfs/boot"
		dd if=/dev/zero of=$BUILD_IMAGES/rootfs.img bs=1M count=0 seek=$IMAGE_SIZE
		sudo mkfs.ext4 -F -L ROOTFS $BUILD_IMAGES/rootfs.img
		rm -rf rootfs && install -d rootfs
		sudo mount -o loop $BUILD_IMAGES/rootfs.img rootfs
	elif [ "$INSTALL_TYPE" == "SD-USB" ]; then
		BOOT_DIR="boot"
		IMAGE_SIZE=$((IMAGE_SIZE + 300)) # SD/USB image szie = BOOT(256MB) + ROOTFS
		dd if=/dev/zero of=${BUILD_IMAGES}/${IMAGE_FILE_NAME} bs=1M count=0 seek=$IMAGE_SIZE
		sudo fdisk "${BUILD_IMAGES}/${IMAGE_FILE_NAME}" <<-EOF
		o
		n
		p
		1
		2048
		524287
		a
		1
		t
		b
		n
		p
		2
		524288

		p
		w

		EOF

		IMAGE_LOOP_DEV="$(sudo losetup --show -f ${BUILD_IMAGES}/${IMAGE_FILE_NAME})"
		export IMAGE_LOOP_DEV
		IMAGE_LOOP_DEV_BOOT="${IMAGE_LOOP_DEV}p1"
		IMAGE_LOOP_DEV_ROOTFS="${IMAGE_LOOP_DEV}p2"
		sudo partprobe "${IMAGE_LOOP_DEV}"
		sudo mkfs.vfat -n BOOT "${IMAGE_LOOP_DEV_BOOT}"
		sudo mkfs.ext4 -F -L ROOTFS "${IMAGE_LOOP_DEV_ROOTFS}"
		rm -rf rootfs boot && install -d rootfs boot
		sudo mount -o loop "${IMAGE_LOOP_DEV_BOOT}" boot
		sudo mount -o loop "${IMAGE_LOOP_DEV_ROOTFS}" rootfs
	else
		error_msg $CURRENT_FILE $LINENO "Unsupported install type: '$INSTALL_TYPE'"
		return -1
	fi

	sudo rm -rf rootfs/lost+found
	if [ "$UBUNTU_TYPE" == "server" ]; then
		# ubuntu-base
		sudo tar -xzf archives/ubuntu-base/$UBUNTU_ROOTFS -C rootfs/
	elif [ "$UBUNTU_TYPE" == "mate" ]; then
		if [ "$UBUNTU_MATE_ROOTFS_TYPE" == "mate-rootfs" ]; then
			# ubuntu-mate
			echo "Extracting ubuntu mate rootfs, please wait..."
			sudo tar -xzf archives/ubuntu-mate/$UBUNTU_ROOTFS -C rootfs/
		elif [ "$UBUNTU_MATE_ROOTFS_TYPE" == "chroot-install" ]; then
			# Install ubuntu mate in chroot, use ubuntu base
			sudo tar -xzf archives/ubuntu-base/$UBUNTU_ROOTFS -C rootfs/
		fi
	fi
	# [Optional] Mirrors for ubuntu-ports
	if [ -f .khadas-build ]; then
		echo "Using ustc mirrors..."
		sudo cp -a rootfs/etc/apt/sources.list rootfs/etc/apt/sources.list.orig
		sudo sed -i "s/http:\/\/ports.ubuntu.com\/ubuntu-ports\//http:\/\/mirrors.ustc.edu.cn\/ubuntu-ports\//g" rootfs/etc/apt/sources.list
	fi

	# FIXME for Ubuntu 14.04, execute /sbin/installkernel failed, so try to install image manually
#	sudo make -C linux/ -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- install INSTALL_PATH=$PWD/${BOOT_DIR}
	install_kernel $(grep "Linux/arm64" $LINUX_DIR/.config | awk  '{print $3}') $LINUX_DIR/arch/arm64/boot/Image $LINUX_DIR/System.map $PWD/${BOOT_DIR}
	if [ "$INSTALL_TYPE" == "SD-USB" ]; then
		# Universal multi-boot
		sudo cp archives/filesystem/boot/* $BOOT_DIR
		if [ "$LINUX" == "mainline" ]; then
			sudo $UTILS_DIR/mkimage -A arm64 -O linux -T script -C none -a 0 -e 0 -n "S905 autoscript" -d $BOOT_DIR/s905_autoscript.cmd.mainline $BOOT_DIR/s905_autoscript
		else
			sudo $UTILS_DIR/mkimage -A arm64 -O linux -T script -C none -a 0 -e 0 -n "S905 autoscript" -d $BOOT_DIR/s905_autoscript.cmd $BOOT_DIR/s905_autoscript
		fi
		sudo $UTILS_DIR/mkimage -A arm64 -O linux -T script -C none -a 0 -e 0 -n "AML autoscript" -d $BOOT_DIR/aml_autoscript.txt $BOOT_DIR/aml_autoscript
		cd $BOOT_DIR
		sudo zip aml_autoscript.zip aml_autoscript aml_autoscript.txt
		cd -
	elif [ "$INSTALL_TYPE" == "EMMC" ]; then
		sudo cp archives/filesystem/boot/hdmi.sh $BOOT_DIR
	fi

	# linux modules
	sudo make -C $LINUX_DIR -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules_install INSTALL_MOD_PATH=$PWD/rootfs/
	sudo make -C $LINUX_DIR -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- headers_install INSTALL_HDR_PATH=$PWD/rootfs/usr/

	# copy linux dtb Image to boot folder
	# FIXME will use deb package in the future
	if [ "$LINUX" == "4.9" -o "$LINUX" == "mainline" ];then
		if [ "$INSTALL_TYPE" == "SD-USB" ]; then
			sudo mkdir -p $BOOT_DIR/dtb
			sudo cp $LINUX_DIR/arch/arm64/boot/dts/amlogic/*.dtb $BOOT_DIR/dtb
		elif [ "$INSTALL_TYPE" == "EMMC" ]; then
			sudo cp $LINUX_DIR/arch/arm64/boot/dts/amlogic/$LINUX_DTB $BOOT_DIR
			## Bakup dtb
			sudo cp $LINUX_DIR/arch/arm64/boot/dts/amlogic/$LINUX_DTB $BOOT_DIR/$LINUX_DTB.old
		fi
	elif [ "$LINUX" == "3.14" ];then
		if [ "$INSTALL_TYPE" == "SD-USB" ];then
			sudo mkdir -p $BOOT_DIR/dtb
			sudo cp $LINUX_DIR/arch/arm64/boot/dts/*.dtb $BOOT_DIR/dtb
		elif [ "$INSTALL_TYPE" == "EMMC" ]; then
			sudo cp $LINUX_DIR/arch/arm64/boot/dts/$LINUX_DTB $BOOT_DIR
			## Backup dtb
			sudo cp $LINUX_DIR/arch/arm64/boot/dts/$LINUX_DTB $BOOT_DIR/$LINUX_DTB.old
		fi
	else
		error_msg $CURRENT_FILE $LINENO "Unsupported linux version:'$LINUX'"
		ret=-1
	fi
	sudo cp $LINUX_DIR/arch/arm64/boot/Image $BOOT_DIR
	# linux version
	grep "Linux/arm64" $LINUX_DIR/.config | awk  '{print $3}' > $BUILD_IMAGES/linux-version
	sudo cp -r $BUILD_IMAGES/linux-version rootfs/
	# initramfs
	sudo cp -r archives/filesystem/etc/initramfs-tools/ rootfs/etc/
	# WIFI
	sudo mkdir -p rootfs/lib/firmware
	sudo cp -r archives/hwpacks/wlan-firmware/brcm/ rootfs/lib/firmware/
	# Bluetooth
	sudo cp -r archives/hwpacks/bluez/brcm_patchram_plus-$UBUNTU_ARCH rootfs/usr/local/bin/brcm_patchram_plus
	sudo cp -r archives/hwpacks/bluez/bluetooth-khadas.service rootfs/lib/systemd/system/
	sudo cp -r archives/hwpacks/bluez/bluetooth-khadas.sh rootfs/usr/local/bin/

	# Install Mali driver
	install_mali_driver

	# Install Kodi
	install_kodi

	sudo cp -arf archives/filesystem/etc rootfs/
	sudo cp -r archives/filesystem/lib/systemd/system/* rootfs/lib/systemd/system/

	if [ "$INSTALL_TYPE" == "EMMC" ]; then
		# firstboot initialization: for 'ROOTFS' partition resize
		# just for EMMC image.
		sudo touch rootfs/etc/default/FIRSTBOOT

		# Remove fstab for EMMC image
		sudo rm rootfs/etc/fstab
	fi

	# mkimage tool
	sudo cp $UTILS_DIR/mkimage-$UBUNTU_ARCH rootfs/usr/local/bin/mkimage

	## script executing on chroot
	sudo cp -r archives/filesystem/RUNME.sh rootfs/

	## Chroot
	if [ "$UBUNTU_ARCH" == "arm64" ]; then
		sudo cp -a /usr/bin/qemu-aarch64-static rootfs/usr/bin/
	elif [ "$UBUNTU_ARCH" == "armhf" ]; then
		sudo cp -a /usr/bin/qemu-arm-static rootfs/usr/bin/
	else
		error_msg $CURRENT_FILE $LINENO "Unsupported ubuntu architecture: '$UBUNTU_ARCH'"
		sudo sync
		sudo umount rootfs
		return -1
	fi

	echo
	echo "NOTE: YOU ARE NOW IN THE VIRTUAL TARGET, SETUP ANYTHING YOU WANT."
	echo "      TYPE 'exit' TO CONTINUE IF FINISHED."
	echo
	sudo mount -o bind /proc rootfs/proc
	sudo mount -o bind /sys rootfs/sys
	sudo mount -o bind /dev rootfs/dev
	sudo mount -o bind /dev/pts rootfs/dev/pts
	sudo chroot rootfs/ bash "/RUNME.sh" $UBUNTU $UBUNTU_TYPE $UBUNTU_ARCH $INSTALL_TYPE ${UBUNTU_MATE_ROOTFS_TYPE:-NONE} $LINUX $KHADAS_BOARD

	## Generate ramdisk.img
	if [ "$INSTALL_TYPE" == "EMMC" ]; then
		cp rootfs/boot/initrd.img $BUILD_IMAGES/initrd.img
		$UTILS_DIR/mkbootimg --kernel $LINUX_DIR/arch/arm64/boot/Image --ramdisk $BUILD_IMAGES/initrd.img -o $BUILD_IMAGES/ramdisk.img
	elif [ "$INSTALL_TYPE" == "SD-USB" ]; then
		sudo cp -r rootfs/boot/* $BOOT_DIR
		sudo rm -rf rootfs/boot/*
	fi

	if [ "$KHADAS_BOARD" == "VIM" ] && [ "$LINUX" == "mainline" ] && [ "$UBUNTU_TYPE" == "mate" ] && [ "$UBUNTU_ARCH" == "arm64" ]; then
		# Mali udev rule
		sudo tee rootfs/etc/udev/rules.d/50-mali.rules <<-EOF
		KERNEL=="mali", MODE="0660", GROUP="video"
		EOF
	fi

	## Logo
	cp archives/logo/logo.img $BUILD_IMAGES

	## Clean up
	sudo rm -f rootfs/boot/initrd.img

	## Unmount to get the rootfs.img
	sudo sync
	sudo umount rootfs/dev/pts
	sudo umount rootfs/dev
	sudo umount rootfs/proc
	if mount | grep "rootfs/sys/kernel/security" > /dev/null; then
		sudo umount rootfs/sys/kernel/security
	fi
	sudo umount rootfs/sys
	sudo umount rootfs

	if [ "$INSTALL_TYPE" == "SD-USB" ]; then
		sudo umount boot
	fi

	return $ret
}

## Pack the images
pack_update_image() {
	cd ${UBUNTU_WORKING_DIR}

	if [ "$INSTALL_TYPE" == "EMMC" ]; then
		if [ $AML_UPDATE_TOOL_CONFIG == "" ]; then
			error_msg $CURRENT_FILE $LINENO "'AML_UPDATE_TOOL_CONFIG' is empty!"
			return -1
		fi

		echo "Packing update image using config: $AML_UPDATE_TOOL_CONFIG"
		$UTILS_DIR/aml_image_v2_packer -r $UPGRADE_DIR/$AML_UPDATE_TOOL_CONFIG $UPGRADE_DIR $BUILD_IMAGES/$IMAGE_FILE_NAME
	elif [ "$INSTALL_TYPE" == "SD-USB" ]; then
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

	echo -e "\nIMAGE: $BUILD_IMAGES/$IMAGE_FILE_NAME"
}

###########################################################
start_time=`date +%s`
check_parameters $@
prepare_toolchains
prepare_packages
prepare_uboot_configuration
prepare_linux_dtb
prepare_git_branch
prepare_ubuntu_rootfs
prepare_working_environment
prepare_aml_update_tool_config
display_parameters
fixup_dtb_link
setup_ubuntu_rootfs
build_uboot
build_linux
build_rootfs
pack_update_image

echo -e "\nDone."
echo -e "\n`date`"

end_time=`date +%s`

time_cal $(($end_time - $start_time))
