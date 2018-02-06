#!/bin/bash

set -e -o pipefail

########################### Parameters ###################################

LINUX_DTB=
LINUX_DIR=


BASE_DIR="$HOME"
PROJECT_DIR="${BASE_DIR}/project"
KHADAS_DIR="${PROJECT_DIR}/khadas"
UBUNTU_WORKING_DIR="$(dirname "$(dirname "$(readlink -fm "$0")")")"
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

## $1 board              	<VIM | VIM2>
## $2 linux version      	<4.9 | 3.14>
## $3 ubuntu architecture   <arm64 | armhf>
check_parameters() {
	if [ "$1" == "" ] || [ "$2" == "" ] || [ "$3" == "" ]; then
		echo "usage: $0 <VIM|VIM2> <4.9|3.14> <arm64|armhf>"
		return -1
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

## Prepare linux directory
prepare_linux_dir() {
	if [ "$LINUX" == "mainline" ]; then
		LINUX_DIR="$BUILD/linux-mainline-*"
	else
		LINUX_DIR="$UBUNTU_WORKING_DIR/linux"
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

remount_rootfs() {
	cd ${UBUNTU_WORKING_DIR}

	IMAGE_LINUX_LOADADDR="0x1080000"
	IMAGE_LINUX_VERSION=`head -n 1 $LINUX_DIR/include/config/kernel.release | xargs echo -n`

	if [ "$INSTALL_TYPE" == "SD-USB" ]; then
		BOOT_DIR="boot"
		IMAGE_LOOP_DEV="$(sudo losetup --show -f ${BUILD_IMAGES}/${IMAGE_FILE_NAME})"
		IMAGE_LOOP_DEV_BOOT="${IMAGE_LOOP_DEV}p1"
		IMAGE_LOOP_DEV_ROOTFS="${IMAGE_LOOP_DEV}p2"
		sudo partprobe "${IMAGE_LOOP_DEV}"
		echo "Mounting ${IMAGE_LOOP_DEV_BOOT}..."
		sudo mount -o loop "${IMAGE_LOOP_DEV_BOOT}" boot || {
			error_msg $CURRENT_FILE $LINENO "Failed to mount $IMAGE_LOOP_DEV_BOOT!"

			return -1
		}
		echo "Mount ${IMAGE_LOOP_DEV_BOOT} on boot/ OK."
		echo "Mountng ${IMAGE_LOOP_DEV_ROOTFS}..."
		sudo mount -o loop "${IMAGE_LOOP_DEV_ROOTFS}" rootfs || {
			sudo sync
			sudo umount boot
			error_msg $CURRENT_FILE $LINENO "Failed to mount $IMAGE_LOOP_DEV_ROOTFS!"

			return -1
		}
		echo "Mount ${IMAGE_LOOP_DEV_ROOTFS} on rootfs/ OK."
	elif [ "$INSTALL_TYPE" == "EMMC" ]; then
		BOOT_DIR="rootfs/boot"
		echo "Mounting rootfs.img..."
		sudo mount -o loop ${BUILD_IMAGES}/rootfs.img rootfs || {
			error_msg $CURRENT_FILE $LINENO "Failed to mount rootfs.img!"

			return -1
		}
		echo "Mount ${BUILD_IMAGES}/rootfs.img on rootfs/ OK."
	fi

	## [Optional] Mirrors for ubuntu-ports
	if [ -f .khadas-build ]; then
		echo "Using ustc mirrors..."
		sudo cp -a rootfs/etc/apt/sources.list rootfs/etc/apt/sources.list.orig
		sudo sed -i "s/http:\/\/ports.ubuntu.com\/ubuntu-ports\//http:\/\/mirrors.ustc.edu.cn\/ubuntu-ports\//g" rootfs/etc/apt/sources.list
	fi

#	sudo make -C $LINUX_DIR -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- install INSTALL_PATH=$PWD/${BOOT_DIR}
	install_kernel $(grep "Linux/arm64" $LINUX_DIR/.config | awk  '{print $3}') $LINUX_DIR/arch/arm64/boot/Image $LINUX_DIR/System.map $PWD/${BOOT_DIR}
	if [ "$INSTALL_TYPE" == "SD-USB" ]; then
		sudo $UTILS_DIR/mkimage -A arm64 -O linux -T kernel -C none -a $IMAGE_LINUX_LOADADDR -e $IMAGE_LINUX_LOADADDR -n linux-$IMAGE_LINUX_VERSION -d $BOOT_DIR/vmlinux-$IMAGE_LINUX_VERSION $BOOT_DIR/uImage
		# Universal multi-boot
		sudo cp archives/filesystem/boot/* $BOOT_DIR
		if [ "$LINUX" == "mainline" ]; then
			sudo $UTILS_DIR/mkimage -A arm64 -O linux -T script -C none -a 0 -e 0 -n "S905 autoscript" -d $BOOT_DIR/s905_autoscript.cmd.mainline $BOOT_DIR/s905_autoscript
		else
			sudo $UTILS_DIR/mkimage -A arm64 -O linux -T script -C none -a 0 -e 0 -n "S905 autoscript" -d $BOOT_DIR/s905_autoscript.cmd $BOOT_DIR/s905_autoscript
		fi
		sudo $UTILS_DIR/mkimage -A arm64 -O linux -T script -C none -a 0 -e 0 -n "AML autoscript" -d $BOOT_DIR/aml_autoscript.txt $BOOT_DIR/aml_autoscript

		cd $BOOT_DIR
		sudo rm aml_autoscript.zip
		sudo zip aml_autoscript.zip aml_autoscript aml_autoscript.txt
		cd -
	fi

	## Update linux modules
	sudo rm -rf rootfs/lib/modules
	sudo make -C $LINUX_DIR -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules_install INSTALL_MOD_PATH=$PWD/rootfs/
	sudo make -C $LINUX_DIR -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- headers_install INSTALL_HDR_PATH=$PWD/rootfs/usr/
	## Update linux dtb Image
	## FIXME will use deb package in the future
	if [ "$LINUX" == "4.9" -o "$LINUX" == "mainline" ];then
		if [ "$INSTALL_TYPE" == "SD-USB" ]; then
			sudo mkdir -p $BOOT_DIR/dtb
			sudo cp $LINUX_DIR/arch/arm64/boot/dts/amlogic/*.dtb $BOOT_DIR/dtb
		elif [ "$INSTALL_TYPE" == "EMMC" ]; then
			sudo cp $LINUX_DIR/arch/arm64/boot/dts/amlogic/$LINUX_DTB $BOOT_DIR
			# Backup dtb
			sudo cp $LINUX_DIR/arch/arm64/boot/dts/amlogic/$LINUX_DTB $BOOTDIR/$LINUX_DTB.old
		fi
	elif [ "$LINUX" == "3.14" ];then
		if [ "$INSTALL_TYPE" == "SD-USB" ]; then
			sudo mkdir -p $BOOT_DIR/dtb
			sudo cp $LINUX_DIR/arch/arm64/boot/dts/*.dtb $BOOT_DIR
		elif [ "$INSTALL_TYPE" == "EMMC" ]; then
			sudo cp $LINUX_DIR/arch/arm64/boot/dts/$LINUX_DTB $BOOT_DIR
			# Backup dtb
			sudo cp $LINUX_DIR/arch/arm64/boot/dts/$LINUX_DTB $BOOT_DIR/$LINUX_DTB.old
		fi
	else
		error_msg $CURRENT_FILE $LINENO "Unsupported linux version:'$LINUX'"
		sudo sync
		sudo umount rootfs
		if [ "$INSTALL_TYPE" == "SD-USB" ]; then
			sudo umount boot
		fi

		return -1
	fi

	sudo cp $LINUX_DIR/arch/arm64/boot/Image $BOOT_DIR

	## linux version
	grep "Linux/arm64" $LINUX_DIR/.config | awk  '{print $3}' > $BUILD_IMAGES/linux-version
	sudo cp -r $BUILD_IMAGES/linux-version rootfs/

	## firstboot initialization: for 'ROOTFS' partition resize
	if [ "$INSTALL_TYPE" == "EMMC" ]; then
		sudo touch rootfs/etc/default/FIRSTBOOT
	fi

	## script executing on chroot
	sudo cp -r archives/filesystem/RUNME_REMOUNT.sh rootfs/

	## Chroot
	if [ "$UBUNTU_ARCH" == "arm64" ]; then
		sudo cp -a /usr/bin/qemu-aarch64-static rootfs/usr/bin/
	elif [ "$UBUNTU_ARCH" == "armhf" ]; then
		sudo cp -a /usr/bin/qemu-arm-static rootfs/usr/bin/
	fi

	sudo mount -o bind /proc rootfs/proc
	sudo mount -o bind /sys rootfs/sys
	sudo mount -o bind /dev rootfs/dev
	sudo mount -o bind /dev/pts rootfs/dev/pts

	while true; do
		read -n1 -p $'\n(A)utorun script, (M)anual chroot or (Q)uit? [a/m/q]' answer
		case $answer in
			[Aa]* )
				echo -e "\nAutorun script."
				sudo chroot rootfs/ bash "/RUNME_REMOUNT.sh" $UBUNTU $INSTALL_TYPE
				break;;
			[Mm]* )
				echo -e "\n\nNOTE: YOU ARE NOW IN THE VIRTUAL TARGET, SETUP ANYTHING YOU WANT."
				echo -e "      TYPE 'exit' TO CONTINUE IF FINISHED.\n"
				sudo chroot rootfs/
				break;;
			[Qq]* )
				echo -e "\nQuit."
				break;;
			* )
				echo -e "\n(A)utorun script, (M)anual chroot or (Q)uit? [a/m/q]"
		esac
	done

	## Generate ramdisk.img
	if [ "$INSTALL_TYPE" == "EMMC" ]; then
		cp rootfs/boot/initrd.img $BUILD_IMAGES/initrd.img
		$UTILS_DIR/mkbootimg --kernel $LINUX_DIR/arch/arm64/boot/Image --ramdisk $BUILD_IMAGES/initrd.img -o $BUILD_IMAGES/ramdisk.img
	elif [ "$INSTALL_TYPE" == "SD-USB" ]; then
		sudo cp -r rootfs/boot/* $BOOT_DIR
		sudo rm -rf rootfs/boot/*
	fi

	## Clean up
	sudo rm -f rootfs/boot/initrd.img

	## Unmount to get the rootfs.img
	sudo sync
	sudo umount rootfs/dev/pts
	sudo umount rootfs/dev
	sudo umount rootfs/proc
	sudo umount rootfs/sys
	sudo umount rootfs

	if [ "$INSTALL_TYPE" == "SD-USB" ]; then
		sudo umount boot
		sudo losetup -d "${IMAGE_LOOP_DEV}"
	fi

	return 0
}


########################################################
check_parameters $@
prepare_linux_dtb
prepare_linux_dir
remount_rootfs

echo -e "\nDone."
echo -e "\n`date`"
