#!/bin/bash

########################### Parameters ###################################

LINUX_DTB=


BASE_DIR="$HOME"
PROJECT_DIR="${BASE_DIR}/project"
KHADAS_DIR="${PROJECT_DIR}/khadas"
UBUNTU_WORKING_DIR="$(dirname "$(dirname "$(readlink -fm "$0")")")"
IMAGE_DIR="images/"
IMAGE_FILE_NAME="KHADAS_${KHADAS_BOARD}_${INSTALL_TYPE}.img"
IMAGE_FILE_NAME=$(echo $IMAGE_FILE_NAME | tr [A-Z] [a-z])

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

## Select linux dtb
prepare_linux_dtb() {
	ret=0
	case "$KHADAS_BOARD" in
		VIM)
			LINUX_DTB="kvim.dtb"
			;;
		VIM2)
			LINUX_DTB="kvim2.dtb"
			;;
		*)
			error_msg $CURRENT_FILE $LINENO "Unsupported board:$KHADAS_BOARD"
			LINUX_DTB=
			ret=-1
			;;
	esac

	return $ret
}

remount_rootfs() {
	cd ${UBUNTU_WORKING_DIR}

	IMAGE_LINUX_LOADADDR="0x1080000"
	IMAGE_LINUX_VERSION=`head -n 1 linux/include/config/kernel.release | xargs echo -n`

	if [ "$INSTALL_TYPE" == "SD-USB" ]; then
		BOOT_DIR="boot"
		IMAGE_LOOP_DEV="$(sudo losetup --show -f ${IMAGE_DIR}${IMAGE_FILE_NAME})"
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
		sudo mount -o loop ${IMAGE_DIR}rootfs.img rootfs || {
			error_msg $CURRENT_FILE $LINENO "Failed to mount rootfs.img!"

			return -1
		}
		echo "Mount ${IMAGE_DIR}rootfs.img on rootfs/ OK."
	fi

	## [Optional] Mirrors for ubuntu-ports
	sudo cp -a rootfs/etc/apt/sources.list rootfs/etc/apt/sources.list.orig
	sudo sed -i "s/http:\/\/ports.ubuntu.com\/ubuntu-ports\//http:\/\/mirrors.ustc.edu.cn\/ubuntu-ports\//g" rootfs/etc/apt/sources.list

	sudo make -C linux/ -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- install INSTALL_PATH=$PWD/${BOOT_DIR}
	if [ "$INSTALL_TYPE" == "SD-USB" ]; then
		sudo ./utils/mkimage -A arm64 -O linux -T kernel -C none -a $IMAGE_LINUX_LOADADDR -e $IMAGE_LINUX_LOADADDR -n linux-$IMAGE_LINUX_VERSION -d $BOOT_DIR/vmlinuz-$IMAGE_LINUX_VERSION $BOOT_DIR/uImage
		sudo cp $BOOT_DIR/uImage $BOOT_DIR/uImag.old
		# Universal multi-boot
		sudo cp archives/filesystem/boot/* $BOOT_DIR
		sudo ./utils/mkimage -A arm64 -O linux -T script -C none -a 0 -e 0 -n "S905 autoscript" -d $BOOT_DIR/s905_autoscript.cmd $BOOT_DIR/s905_autoscript
		sudo ./utils/mkimage -A arm64 -O linux -T script -C none -a 0 -e 0 -n "AML autoscript" -d $BOOT_DIR/aml_autoscript.txt $BOOT_DIR/aml_autoscript
		cd $BOOT_DIR
		sudo rm aml_autoscript.zip
		sudo zip aml_autoscript.zip aml_autoscript aml_autoscript.txt
		cd -
	fi

	## Update linux modules
	sudo make -C linux/ -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules_install INSTALL_MOD_PATH=../rootfs/
	sudo make -C linux/ -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- headers_install INSTALL_HDR_PATH=$PWD/rootfs/usr/
	## Update linux dtb Image
	if [ "$LINUX" == "4.9" ];then
		sudo cp linux/arch/arm64/boot/dts/amlogic/$LINUX_DTB $BOOT_DIR
		# Backup dtb
		sudo cp linux/arch/arm64/boot/dts/amlogic/$LINUX_DTB $BOOTDIR/$LINUX_DTB.old
	elif [ "$LINUX" == "3.14" ];then
		sudo cp linux/arch/arm64/boot/dts/$LINUX_DTB $BOOT_DIR
		# Backup dtb
		sudo cp linux/arch/arm64/boot/dts/$LINUX_DTB $BOOT_DIR/$LINUX_DTB.old
	else
		error_msg $CURRENT_FILE $LINENO "Unsupported linux version:'$LINUX'"
		sudo sync
		sudo umount rootfs
		if [ "$INSTALL_TYPE" == "SD-USB" ]; then
			sudo umount boot
		fi

		return -1
	fi

	sudo cp linux/arch/arm64/boot/Image $BOOT_DIR

	## linux version
	grep "Linux/arm64" linux/.config | awk  '{print $3}' > images/linux-version
	sudo cp -r images/linux-version rootfs/

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
		cp rootfs/boot/initrd.img images/initrd.img
		./utils/mkbootimg --kernel linux/arch/arm64/boot/Image --ramdisk images/initrd.img -o images/ramdisk.img
	elif [ "$INSTALL_TYPE" == "SD-USB" ]; then
		sudo mv rootfs/boot/uInitrd $BOOT_DIR
		sudo cp $BOOT_DIR/uInitrd $BOOT_DIR/uInitrd.old
	fi

	## Clean up
	sudo rm rootfs/boot/initrd.img

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
check_parameters $@         &&
prepare_linux_dtb           &&
remount_rootfs              &&

echo -e "\nDone."
echo -e "\n`date`"
