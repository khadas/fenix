#!/bin/bash

set -e -o pipefail

## Parameters
source config/config

## Board configuraions
source ${BOARD_CONFIG}/${KHADAS_BOARD}.conf

## Functions
source config/functions/functions

######################################################################################

UBUNTU_VER=

## Try to update Fenix
check_update() {
	cd $ROOT

	update_git_repo "$PWD" "master"
}

## Select ubuntu rootfs
prepare_ubuntu_rootfs() {
	ret=0

	if [ "$UBUNTU_ARCH" != "arm64" ] && [ "$UBUNTU_ARCH" != "armhf" ]; then
		error_msg "Unsupported ubuntu architecture: $UBUNTU_ARCH"
		return -1
	fi

	# FIXME
	if [ "$UBUNTU" == "16.04" ]; then
		UBUNTU_VER="16.04.2"
	else
		UBUNTU_VER=$UBUNTU
	fi

	if [ "$UBUNTU_TYPE" == "server" ] || [ "$UBUNTU_MATE_ROOTFS_TYPE" == "chroot-install" ]; then
		UBUNTU_ROOTFS="ubuntu-base-${UBUNTU_VER}-base-$UBUNTU_ARCH.tar.gz"
	elif [ "$UBUNTU_TYPE" == "mate" ]; then
		if [ "$UBUNTU" == "16.04" ]; then
			UBUNTU_ROOTFS="ubuntu-mate-${UBUNTU_VER}-$UBUNTU_ARCH.tar.gz"
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
	echo "root directory:                $ROOT"
	echo "image directory:               $BUILD_IMAGES"
	echo "image file name:               $IMAGE_FILE_NAME"
	echo "*********************************************************"
	echo ""
}

## Prepare working environment
prepare_working_environment() {

	install -d ${ROOT}/archives/{ubuntu-base,ubuntu-mate}

	cd ${ROOT}

	return 0
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
		cd ${ROOT}/archives/ubuntu-base
	elif [ "$UBUNTU_TYPE" == "mate" ]; then
		IMAGE_SIZE=$UBUNTU_MATE_IMAGE_SIZE
		if [ "$UBUNTU_MATE_ROOTFS_TYPE" == "mate-rootfs" ]; then
			if [ "$UBUNTU" == "16.04" ]; then
				cd ${ROOT}/archives/ubuntu-mate
			else
				error_msg "Ubuntu mate $UBUNTU is not supported to build use ubuntu mate rootfs now!" && return -1
			fi
		elif [ "$UBUNTU_MATE_ROOTFS_TYPE" == "chroot-install" ]; then
			cd ${ROOT}/archives/ubuntu-base
		fi
	fi

	if [ ! -f $UBUNTU_ROOTFS ]; then
		if [ "$UBUNTU_TYPE" == "server" ] || [ "$UBUNTU_MATE_ROOTFS_TYPE" == "chroot-install" ]; then
			echo "'$UBUNTU_ROOTFS' does not exist, begin to downloading..."
			wget http://cdimage.ubuntu.com/ubuntu-base/releases/$UBUNTU/release/$UBUNTU_ROOTFS
		elif [ "$UBUNTU_TYPE" == "mate" ]; then
			if [ "$UBUNTU" == "16.04" ]; then
				## FIXME
				error_msg "'$UBUNTU_ROOTFS' does not exist, please download it into folder '`pwd`' manually, and try again! Yon can refer to 'http://www.mediafire.com/file/sthi6u5gf7vxymz/ubuntu-mate-16.04.2-arm64.tar.gz' for ubuntu mate $UBUNTU rootfs." && ret=-1
			else
				error_msg "Ubuntu mate $UBUNTU is not supported to build use ubuntu mate rootfs now!" && ret=-1
			fi
		fi

		[ $? != 0 ] && error_msg "Failed to download '$UBUNTU_ROOTFS'" && ret=-1
	fi

	cd -

	return $ret
}

## Install kodi
install_kodi() {
	if [ "$KHADAS_BOARD" == "VIM" ] && [ "$LINUX" == "3.14" ] && [ "$UBUNTU_TYPE" == "mate" ]; then
		build_package "pkg-aml-kodi:target"
		build_package "pkg-aml-codec:target"
		build_package "pkg-aml-amremote:target"

		cd $ROOT
		sudo mkdir -p $ROOTFS/tempdebs
		sudo cp $BUILD_IMAGES/pkg-aml-kodi/*.deb $ROOTFS/tempdebs
		sudo cp $BUILD_IMAGES/pkg-aml-codec/*.deb $ROOTFS/tempdebs
		sudo cp $BUILD_IMAGES/pkg-aml-amremote/*.deb $ROOTFS/tempdebs
	fi
}

## Install xserver
install_xserver() {
	if [ "$VENDER" == "Rockchip" ] && [ "$UBUNTU_TYPE" == "mate" ]; then
		echo "Install xserver..."
		build_package "xserver_rk3399:target"
		cd $ROOT
		sudo mkdir -p $ROOTFS/tempdebs
		sudo cp $BUILD_DEBS/xserver-*.deb $ROOTFS/tempdebs
	fi
}

## Rootfs
build_rootfs() {
	ret=0
	cd ${ROOT}

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
	build_linux_debs

	# linux version
	echo $IMAGE_LINUX_VERSION > $BUILD_IMAGES/linux-version
	sudo cp -r $BUILD_IMAGES/linux-version $ROOTFS/

	# Build GPU deb
	build_gpu_deb

	# Install Kodi
	install_kodi

	# Build board deb
	build_board_deb

	# Install xserver
	install_xserver

	if [ "$INSTALL_TYPE" == "EMMC" ]; then
		# firstboot initialization: for 'ROOTFS' partition resize
		# just for EMMC image.
		sudo touch $ROOTFS/etc/default/FIRSTBOOT
	fi

	# mkimage tool
	sudo cp $UTILS_DIR/mkimage-$UBUNTU_ARCH $ROOTFS/usr/local/bin/mkimage

	## script executing on chroot
	sudo cp -r scripts/chroot-scripts/RUNME.sh $ROOTFS/

	## Prepare chroot
	prepare_chroot

	echo
	echo "NOTE: YOU ARE NOW IN THE VIRTUAL TARGET, SETUP ANYTHING YOU WANT."
	echo "      TYPE 'exit' TO CONTINUE IF FINISHED."
	echo
	mount_chroot "$ROOTFS"
	sudo chroot $ROOTFS/ bash "/RUNME.sh" $UBUNTU $UBUNTU_TYPE $UBUNTU_ARCH $INSTALL_TYPE ${UBUNTU_MATE_ROOTFS_TYPE:-NONE} $LINUX $KHADAS_BOARD $VENDER

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
	umount_chroot "$ROOTFS"

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
prepare_ubuntu_rootfs
prepare_working_environment
display_parameters
setup_ubuntu_rootfs
build_uboot
build_linux
build_rootfs
pack_image_platform

echo -e "\nDone."
echo -e "\n`date`"

end_time=`date +%s`

time_cal $(($end_time - $start_time))
