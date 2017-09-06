#!/bin/bash

########################### Parameters ###################################

LINUX_DTB=


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

	echo "Mount rootfs.img..."
	sudo mount -o loop images/rootfs.img rootfs
	[ $? != 0 ] && error_msg $CURRENT_FILE $LINENO "Failed to mount rootfs.img!" && return -1
	echo "Mount image/rootfs.img on rootfs/ OK."

	## [Optional] Mirrors for ubuntu-ports
	sudo cp -a rootfs/etc/apt/sources.list rootfs/etc/apt/sources.list.orig
	sudo sed -i "s/http:\/\/ports.ubuntu.com\/ubuntu-ports\//http:\/\/mirrors.ustc.edu.cn\/ubuntu-ports\//g" rootfs/etc/apt/sources.list
	## Update linux modules
	sudo make -C linux/ -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules_install INSTALL_MOD_PATH=../rootfs/
	## Update linux dtb Image
	if [ "$LINUX" == "4.9" ];then
		sudo cp linux/arch/arm64/boot/dts/amlogic/$LINUX_DTB rootfs/boot/
		# Backup dtb
		sudo cp linux/arch/arm64/boot/dts/amlogic/$LINUX_DTB rootfs/boot/$LINUX_DTB.old
	elif [ "$LINUX" == "3.14" ];then
		sudo cp linux/arch/arm64/boot/dts/$LINUX_DTB rootfs/boot/
		# Backup dtb
		sudo cp linux/arch/arm64/boot/dts/$LINUX_DTB rootfs/boot/$LINUX_DTB.old
	else
		error_msg $CURRENT_FILE $LINENO "Unsupported linux version:'$LINUX'"
		sudo sync
		sudo umount rootfs
		return -1
	fi

	sudo cp linux/arch/arm64/boot/Image rootfs/boot/

	## linux version
	grep "Linux/arm64" linux/.config | awk  '{print $3}' > images/linux-version
	sudo cp -r images/linux-version rootfs/

	## firstboot initialization: for 'ROOTFS' partition resize
	sudo touch rootfs/etc/default/FIRSTBOOT

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
				sudo chroot rootfs/ bash "/RUNME_REMOUNT.sh" $UBUNTU
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
	cp rootfs/boot/initrd.img images/initrd.img
	./utils/mkbootimg --kernel linux/arch/arm64/boot/Image --ramdisk images/initrd.img -o images/ramdisk.img

	## Clean up
	sudo rm rootfs/boot/initrd.img

	## Unmount to get the rootfs.img
	sudo sync
	sudo umount rootfs/dev/pts
	sudo umount rootfs/dev
	sudo umount rootfs/proc
	sudo umount rootfs/sys
	sudo umount rootfs

	return 0
}


########################################################
check_parameters $1 $2 $3   &&
prepare_linux_dtb           &&
remount_rootfs              &&

echo -e "\nDone."
echo -e "\n`date`"
