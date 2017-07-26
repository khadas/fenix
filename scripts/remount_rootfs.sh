#!/bin/bash

########################### Parameters ###################################

BASE_DIR="$HOME"
PROJECT_DIR="${BASE_DIR}/project"
KHADAS_DIR="${PROJECT_DIR}/khadas"
UBUNTU_WORKING_DIR="${KHADAS_DIR}/ubuntu"

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


remount_rootfs() {
	cd ${UBUNTU_WORKING_DIR}

	echo "Mount rootfs.img..."
	sudo mount -o loop images/rootfs.img rootfs
	[ $? != 0 ] && error_msg $CURRENT_FILE $LINENO "Failed to mount rootfs.img!" && return -1
	echo "Mount image/rootfs.img on rootfs/ OK."

	## linux version
	grep "Linux/arm64" linux/.config | awk  '{print $3}' > images/linux-version
	sudo cp -r images/linux-version rootfs/

	## script executing on chroot
	sudo cp -r archives/filesystem/RUNME.sh rootfs/

	## Chroot
	sudo cp -a /usr/bin/qemu-aarch64-static rootfs/usr/bin/
	echo
	echo "NOTE: YOU ARE NOW IN THE VIRTUAL TARGET, SETUP ANYTHING YOU WANT."
	echo "      TYPE 'exit' TO CONTINUE IF FINISHED."
	echo
	sudo mount -o bind /proc rootfs/proc
	sudo mount -o bind /sys rootfs/sys
	sudo mount -o bind /dev rootfs/dev
	sudo mount -o bind /dev/pts rootfs/dev/pts
	sudo chroot rootfs/

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
remount_rootfs			&&

echo -e "\nDone."
echo -e "\n`date`"
