#!/bin/bash

set -e -o pipefail

########################### Parameters ###################################
source config/config

############################## Functions #################################
source config/functions

## Update git repository
## $1 git repository path
## $2 git branch
update_git_repo() {
	if [ ! -f $UBUNTU_WORKING_DIR/.ignore-update ]; then
		if [ "$1" == "" ] || [ "$2" == 0 ]; then
			echo "Usage: $0 <repository_path> <git_branch>"
			return -1
		fi

		cd $1
		if [ ! -d .git ]; then
			error_msg "No Git repository found!"
			cd -
			return -1
		fi

		echo "Try to update `basename $1`:$2"
		if ! git branch | grep "^* $2$" > /dev/null; then
			git checkout $2
		fi
		git pull origin $2
		CHANGED_FILES=$(git diff --name-only)
		if [ -n "$CHANGED_FILES" ]; then
			echo -e "$WARNING Can't update since you made changes to: \e[0;32m\n${CHANGED_FILES}\x1B[0m"
			echo -e "Press \e[0;33m<Ctrl-C>\x1B[0m to abort compilation, \e[0;33m<Enter>\x1B[0m to ignore and continue"
			read
		fi

		cd -
	fi
}

## Try to update Fenix
check_update() {
	cd $UBUNTU_WORKING_DIR

	update_git_repo "$PWD" "master"
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
			error_msg "Package name mismatch! '$PKG_NAME' != '$PKG'"
			return -1
		fi
	else
		error_msg "Package '$PKG' doesn't exist!"
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

			error_msg "Incorrect checksum calculated on downloaded file: got ${CALC_SHA256}, wanted ${PKG_SHA256}"
		fi
		NBWGET=$((NBWGET - 1))
	done

	if [ $NBWGET -eq 0 ]; then
		error_msg "Cant't get $PKG_NAME sources : $PKG_URL\n Try later !!"
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
				error_msg "error: File $PKG_SOURCE_NAME doesn't exist in package $1 downloads directory"
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
		error_msg "$1: no package.mk file found!"
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

## Select ubuntu rootfs
prepare_ubuntu_rootfs() {
	ret=0

	if [ "$UBUNTU_ARCH" != "arm64" ] && [ "$UBUNTU_ARCH" != "armhf" ]; then
		error_msg "Unsupported ubuntu architecture: $UBUNTU_ARCH"
		return -1
	fi

	if [ "$UBUNTU_TYPE" == "server" ] || [ "$UBUNTU_MATE_ROOTFS_TYPE" == "chroot-install" ]; then
		UBUNTU_ROOTFS="ubuntu-base-$UBUNTU-base-$UBUNTU_ARCH.tar.gz"
	elif [ "$UBUNTU_TYPE" == "mate" ]; then
		if [ "$UBUNTU" == "16.04.2" ]; then
			UBUNTU_ROOTFS="ubuntu-mate-$UBUNTU-$UBUNTU_ARCH.tar.gz"
		else
			error_msg "Unsupported ubuntu version:$UBUNTU_TYPE $UBUNTU for $UBUNTU_MATE_ROOTFS_TYPE"
			UBUNTU_ROOTFS=
			ret=-1
		fi
	else
		error_msg "Unsupported ubuntu image type:$UBUNTU_TYPE"
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
	echo "ubuntu working directory:      $UBUNTU_WORKING_DIR"
	echo "amlogic update tool config:    $AML_UPDATE_TOOL_CONFIG"
	echo "image directory:               $BUILD_IMAGES"
	echo "image file name:               $IMAGE_FILE_NAME"
	echo "*********************************************************"
	echo ""
}

## Prepare working environment
prepare_working_environment() {

	install -d ${UBUNTU_WORKING_DIR}/archives/{ubuntu-base,ubuntu-mate}

	cd ${UBUNTU_WORKING_DIR}

	prepare_linux_dir

	return 0
}

## Build U-Boot
build_uboot() {
	ret=0

	if [ "$UBOOT" == "mainline" ]; then
		return 0
	fi

	if [ "$UBOOT_GIT_BRANCH" == "" ]; then
		error_msg "'UBOOT_GIT_BRANCH' is empty!"
		return -1
	fi

	cd ${UBUNTU_WORKING_DIR}
	if [ ! -d u-boot/.git ]; then
		echo "U-boot repository does not exist, clone u-boot repository('$UBOOT_GIT_BRANCH') form Khadas GitHub..."
		## Clone u-boot from Khadas GitHub
		git clone https://github.com/khadas/u-boot -b $UBOOT_GIT_BRANCH
		[ $? != 0 ] && error_msg "Failed to clone 'u-boot'" && return -1
	fi

	cd u-boot/

	if ! git branch | grep "^* $UBOOT_GIT_BRANCH$" > /dev/null; then
		if ! git branch | grep "^  $UBOOT_GIT_BRANCH$" > /dev/null; then
			# New branch? Try to fetch it.
			echo "Fetching '$UBOOT_GIT_BRANCH' from Khadas GitHub..."
			git fetch origin $UBOOT_GIT_BRANCH:$UBOOT_GIT_BRANCH
		fi

		echo "U-boot: Switch to branch '$UBOOT_GIT_BRANCH'"
		make distclean
		git checkout $UBOOT_GIT_BRANCH
		[ $? != 0 ] && error_msg "U-boot: Switch to branch '$UBOOT_GIT_BRANCH' failed." && return -1
	else
		echo "U-boot: Already on branch '$UBOOT_GIT_BRANCH'"
	fi

	# Update u-boot
	update_git_repo "$PWD" "$UBOOT_GIT_BRANCH"

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
		[ "$LINUX_GIT_BRANCH" == "" ] && error_msg "'LINUX_GIT_BRANCH' is empty!"
		[ "$LINUX_DTB" == "" ] && error_msg "'LINUX_DTB' is empty!"
		return -1
	fi

	cd ${UBUNTU_WORKING_DIR}
	if [ ! -d linux/.git ]; then
		echo "Linux repository does not exist, clone linux repository('$LINUX_GIT_BRANCH') form Khadas GitHub..."
		## Clone linux from Khadas GitHub
		git clone https://github.com/khadas/linux -b $LINUX_GIT_BRANCH
		[ $? != 0 ] && error_msg "Failed to clone 'linux'" && return -1
	fi

	cd linux/
	touch .scmversion

	if ! git branch | grep "^* $LINUX_GIT_BRANCH$" > /dev/null; then
		if ! git branch | grep "^  $LINUX_GIT_BRANCH$" > /dev/null; then
			# New branch? Try to fetch it.
			echo "Fetching '$LINUX_GIT_BRANCH' from Khadas GitHub..."
			git fetch origin $LINUX_GIT_BRANCH:$LINUX_GIT_BRANCH
		fi

		echo "Linux: Switch to branch '$LINUX_GIT_BRANCH'"
		make ARCH=arm64 distclean
		git checkout $LINUX_GIT_BRANCH
		[ $? != 0 ] && error_msg "Linux: Switch to branch '$LINUX_GIT_BRANCH' failed." && return -1
	else
		echo "Linux: Already on branch '$LINUX_GIT_BRANCH'"
	fi

	# Update linux
	update_git_repo "$PWD" "$LINUX_GIT_BRANCH"

	echo "Build linux..."
	export PATH=$TOOLCHAINS/gcc-linaro-aarch64-linux-gnu/bin:$PATH
	make ARCH=arm64 kvim_defconfig
	make -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image dtbs  modules
}

## Setup ubuntu rootfs
setup_ubuntu_rootfs() {
	ret=0
	if [ "$UBUNTU_ROOTFS" == "" ]; then
		error_msg "'UBUNTU_ROOTFS' is empty!"
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
				error_msg "Ubuntu mate $UBUNTU is not supported to build use ubuntu mate rootfs now!" && return -1
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
				error_msg "'$UBUNTU_ROOTFS' does not exist, please download it into folder '`pwd`' manually, and try again! Yon can refer to 'http://www.mediafire.com/file/sthi6u5gf7vxymz/ubuntu-mate-16.04.2-arm64.tar.gz' for ubuntu mate 16.04.2 rootfs." && ret=-1
			else
				error_msg "Ubuntu mate $UBUNTU is not supported to build use ubuntu mate rootfs now!" && ret=-1
			fi
		fi

		[ $? != 0 ] && error_msg "Failed to download '$UBUNTU_ROOTFS'" && ret=-1
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
		sudo cp -arf archives/hwpacks/mali/r7p0/include/EGL $ROOTFS/usr/include/
		sudo cp -arf archives/hwpacks/mali/r7p0/include/GLES $ROOTFS/usr/include/
		sudo cp -arf archives/hwpacks/mali/r7p0/include/GLES2 $ROOTFS/usr/include/
		sudo cp -arf archives/hwpacks/mali/r7p0/include/KHR $ROOTFS/usr/include/

		### fbdev
		sudo cp -arf archives/hwpacks/mali/r7p0/include/EGL_platform/platform_fbdev/*.h $ROOTFS/usr/include/EGL/

		### wayland
		### sudo cp -arf archives/hwpacks/mali/r7p0/include/EGL_platform/platform_wayland/*.h $ROOTFS/usr/include/EGL/
		## libMali.so
		### fbdev
		if [ "$UBUNTU_ARCH" == "arm64" ]; then
			sudo cp -arf archives/hwpacks/mali/r7p0/lib/arm64/$GPU_VER/m450/*.so* $ROOTFS/usr/lib/
			sudo cp -arf archives/hwpacks/mali/r7p0/lib/arm64/$GPU_VER/m450/*.so* $ROOTFS/usr/lib/aarch64-linux-gnu
		elif [ "$UBUNTU_ARCH" == "armhf" ]; then
			sudo cp -arf archives/hwpacks/mali/r7p0/lib/eabihf/$GPU_VER/m450/*.so* $ROOTFS/usr/lib/
			sudo cp -arf archives/hwpacks/mali/r7p0/lib/eabihf/$GPU_VER/m450/*.so* $ROOTFS/usr/lib/arm-linux-gnueabihf
		fi

		### wayland
		### if [ "$UBUNTU_ARCH" == "arm64" ]; then
		###     sudo cp -arf archives/hwpacks/mali/r7p0/lib/arm64/r7p0/m450/wayland/*.so* $ROOTFS/usr/lib/
		###     sudo cp -arf archives/hwpacks/mali/r7p0/lib/arm64/r7p0/m450/wayland/*.so* $ROOTFS/usr/lib/aarch64-linux-gnu
		###elif [ "$UBUNTU_ARCH" == "armhf" ]; then
		###     sudo cp -arf archives/hwpacks/mali/r7p0/lib/eabihf/r7p0/m450/wayland/*.so* $ROOTFS/usr/lib/
		###     sudo cp -arf archives/hwpacks/mali/r7p0/lib/eabihf/r7p0/m450/wayland/*.so* $ROOTFS/usr/lib/arm-linux-gnueabihf
		### fi

		### links
		sudo cp -arf archives/hwpacks/mali/r7p0/lib/*.so* $ROOTFS/usr/lib/
		if [ "$UBUNTU_ARCH" == "arm64" ]; then
			sudo cp -arf archives/hwpacks/mali/r7p0/lib/*.so* $ROOTFS/usr/lib/aarch64-linux-gnu
		elif [ "$UBUNTU_ARCH" == "armhf" ]; then
			sudo cp -arf archives/hwpacks/mali/r7p0/lib/*.so* $ROOTFS/usr/lib/arm-linux-gnueabihf
		fi
			sudo mkdir -p $ROOTFS/usr/lib/pkgconfig/
			sudo cp -arf archives/hwpacks/mali/r7p0/lib/pkgconfig/*.pc $ROOTFS/usr/lib/pkgconfig/
		# Mali m450 framebuffer mode examples
		if [ "$UBUNTU_ARCH" == "arm64" ]; then
			sudo mkdir -p $ROOTFS/usr/share/arm/
			sudo cp -arf archives/hwpacks/mali/fbdev_examples/$LINUX/lib/* $ROOTFS/usr/lib/
			sudo cp -arf archives/hwpacks/mali/fbdev_examples/$LINUX/opengles_20 $ROOTFS/usr/share/arm/
		fi

		sudo mkdir -p $ROOTFS/usr/lib/udev/rules.d
		sudo cp -arf archives/filesystem/usr/lib/udev/rules.d/* $ROOTFS/usr/lib/udev/rules.d

	elif [ "$KHADAS_BOARD" == "VIM" ] && [ "$LINUX" == "mainline" ] && [ "$UBUNTU_TYPE" == "mate" ] && [ "$UBUNTU_ARCH" == "arm64" ]; then
		# VIM mainline X11 mali driver
		## install mali.ko
		build_package "meson-gx-mali-450:target"
		VER=$(ls $ROOTFS/lib/modules/)
		sudo cp $BUILD/meson-gx-mali-450-*/mali.ko $ROOTFS/lib/modules/$VER/kernel/
		sudo depmod -b $ROOTFS/ -a $VER
		## libMali X11
		cd $UBUNTU_WORKING_DIR
		sudo mkdir -p $ROOTFS/usr/lib/mali
		sudo cp archives/hwpacks/mali/r7p0/lib/arm64/r7p0/m450-X/libMali.so $ROOTFS/usr/lib/mali/
		cd $ROOTFS/usr/lib/mali
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
		sudo cp -ar archives/hwpacks/mali/r7p0/include/* $ROOTFS/usr/include/
		sudo tee "$ROOTFS/etc/ld.so.conf.d/mali.conf" <<-EOF
		/usr/lib/mali
		EOF
		build_package "xf86-video-armsoc:target"
		sudo cp -r $BUILD/xf86-video-armsoc-* $ROOTFS/xf86-video-armsoc

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
		sudo cp $BUILD_IMAGES/pkg-aml-kodi/*.deb $ROOTFS/
		sudo cp $BUILD_IMAGES/pkg-aml-codec/*.deb $ROOTFS/
		sudo cp $BUILD_IMAGES/pkg-aml-amremote/*.deb $ROOTFS/
	fi
}

## Rootfs
build_rootfs() {
	ret=0
	cd ${UBUNTU_WORKING_DIR}

	trap cleanup INT EXIT TERM

	IMAGE_LINUX_LOADADDR="0x1080000"
	IMAGE_LINUX_VERSION=`head -n 1 $LINUX_DIR/include/config/kernel.release | xargs echo -n`

	mkdir -p $BUILD_IMAGES

	if [ "$INSTALL_TYPE" == "EMMC" ]; then
		dd if=/dev/zero of=$BUILD_IMAGES/rootfs.img bs=1M count=0 seek=$IMAGE_SIZE
		sudo mkfs.ext4 -F -L ROOTFS $BUILD_IMAGES/rootfs.img
		rm -rf $ROOTFS && install -d $ROOTFS
		sudo mount -o loop $BUILD_IMAGES/rootfs.img $ROOTFS
	elif [ "$INSTALL_TYPE" == "SD-USB" ]; then
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
		sudo rm -rf $ROOTFS && sudo mkdir -p $ROOTFS
		sudo mount -o loop "${IMAGE_LOOP_DEV_ROOTFS}" $ROOTFS
		sudo mkdir -p $ROOTFS/boot
		sudo mount -o loop "${IMAGE_LOOP_DEV_BOOT}" $ROOTFS/boot
	else
		error_msg "Unsupported install type: '$INSTALL_TYPE'"
		return -1
	fi

	sudo rm -rf $ROOTFS/lost+found
	if [ "$UBUNTU_TYPE" == "server" ]; then
		# ubuntu-base
		sudo tar -xzf archives/ubuntu-base/$UBUNTU_ROOTFS -C $ROOTFS/
	elif [ "$UBUNTU_TYPE" == "mate" ]; then
		if [ "$UBUNTU_MATE_ROOTFS_TYPE" == "mate-rootfs" ]; then
			# ubuntu-mate
			echo "Extracting ubuntu mate rootfs, please wait..."
			sudo tar -xzf archives/ubuntu-mate/$UBUNTU_ROOTFS -C $ROOTFS/
		elif [ "$UBUNTU_MATE_ROOTFS_TYPE" == "chroot-install" ]; then
			# Install ubuntu mate in chroot, use ubuntu base
			sudo tar -xzf archives/ubuntu-base/$UBUNTU_ROOTFS -C $ROOTFS/
		fi
	fi
	# [Optional] Mirrors for ubuntu-ports
	if [ -f .khadas-build ]; then
		echo "Using ustc mirrors..."
		sudo cp -a $ROOTFS/etc/apt/sources.list $ROOTFS/etc/apt/sources.list.orig
		sudo sed -i "s/http:\/\/ports.ubuntu.com\/ubuntu-ports\//http:\/\/mirrors.ustc.edu.cn\/ubuntu-ports\//g" $ROOTFS/etc/apt/sources.list
	fi

	# Hack for deb builder. To pack what's missing in headers pack.
	cp archives/patches/misc/headers-debian-byteshift.patch /tmp

	# Different packaging for 4.3+
	if linux-version compare $IMAGE_LINUX_VERSION ge 4.3; then
		KERNEL_PACKING="bindeb-pkg"
	else
		KERNEL_PACKING="deb-pkg"
	fi

	# Build linux debs
	make -j1 -C $LINUX_DIR $KERNEL_PACKING KDEB_PKGVERSION="$VERSION" LOCAL_VERSION=$(echo "-${VENDER}-${CHIP}" | tr "[A-Z]" "[a-z]") KBUILD_DEBARCH="$UBUNTU_ARCH" ARCH=arm64 DEBFULLNAME="Khadas" DEBEMAIL="hello@khadas.com" CROSS_COMPILE="aarch64-linux-gnu-"

	# Move debs to rootfs, will be installed in chroot
	sudo mv *.deb $ROOTFS

	# linux version
	echo $IMAGE_LINUX_VERSION > $BUILD_IMAGES/linux-version
	sudo cp -r $BUILD_IMAGES/linux-version $ROOTFS/

	# Install Mali driver
	install_mali_driver

	# Install Kodi
	install_kodi

	# Create board package
	create_board_package

	if [ "$INSTALL_TYPE" == "EMMC" ]; then
		# firstboot initialization: for 'ROOTFS' partition resize
		# just for EMMC image.
		sudo touch $ROOTFS/etc/default/FIRSTBOOT
	fi

	# mkimage tool
	sudo cp $UTILS_DIR/mkimage-$UBUNTU_ARCH $ROOTFS/usr/local/bin/mkimage

	## script executing on chroot
	sudo cp -r archives/chroot-scripts/RUNME.sh $ROOTFS/

	## Chroot
	if [ "$UBUNTU_ARCH" == "arm64" ]; then
		sudo cp -a /usr/bin/qemu-aarch64-static $ROOTFS/usr/bin/
	elif [ "$UBUNTU_ARCH" == "armhf" ]; then
		sudo cp -a /usr/bin/qemu-arm-static $ROOTFS/usr/bin/
	else
		error_msg "Unsupported ubuntu architecture: '$UBUNTU_ARCH'"
		sudo sync
		sudo umount $ROOTFS
		return -1
	fi

	echo
	echo "NOTE: YOU ARE NOW IN THE VIRTUAL TARGET, SETUP ANYTHING YOU WANT."
	echo "      TYPE 'exit' TO CONTINUE IF FINISHED."
	echo
	sudo mount -o bind /proc $ROOTFS/proc
	sudo mount -o bind /sys $ROOTFS/sys
	sudo mount -o bind /dev $ROOTFS/dev
	sudo mount -o bind /dev/pts $ROOTFS/dev/pts
	sudo chroot $ROOTFS/ bash "/RUNME.sh" $UBUNTU $UBUNTU_TYPE $UBUNTU_ARCH $INSTALL_TYPE ${UBUNTU_MATE_ROOTFS_TYPE:-NONE} $LINUX $KHADAS_BOARD

	if [ "$KHADAS_BOARD" == "VIM" ] && [ "$LINUX" == "mainline" ] && [ "$UBUNTU_TYPE" == "mate" ] && [ "$UBUNTU_ARCH" == "arm64" ]; then
		# Mali udev rule
		sudo tee $ROOTFS/etc/udev/rules.d/50-mali.rules <<-EOF
		KERNEL=="mali", MODE="0660", GROUP="video"
		EOF
	fi

	## Logo
	cp archives/logo/logo.img $BUILD_IMAGES

	## Unmount to get the rootfs.img
	sudo sync
	sudo umount $ROOTFS/dev/pts
	sudo umount $ROOTFS/dev
	sudo umount $ROOTFS/proc
	if mount | grep "$ROOTFS/sys/kernel/security" > /dev/null; then
		sudo umount $ROOTFS/sys/kernel/security
	fi
	sudo umount $ROOTFS/sys

	if [ "$INSTALL_TYPE" == "SD-USB" ]; then
		sudo umount $ROOTFS/boot
		sudo losetup -d "${IMAGE_LOOP_DEV}"
	fi
	sudo umount $ROOTFS

	trap - INT EXIT TERM

	return $ret
}

###########################################################
start_time=`date +%s`
prepare_host
check_update
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
