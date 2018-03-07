#!/bin/bash

set -e -o pipefail

########################### Parameters ###################################
source config/config

############################## Functions #################################
source config/functions

remount_rootfs() {
	cd ${UBUNTU_WORKING_DIR}

	trap cleanup INT EXIT TERM

	IMAGE_LINUX_LOADADDR="0x1080000"
	IMAGE_LINUX_VERSION=`head -n 1 $LINUX_DIR/include/config/kernel.release | xargs echo -n`

	if [ "$INSTALL_TYPE" == "SD-USB" ]; then
		BOOT_DIR="$BOOT"
		IMAGE_LOOP_DEV="$(sudo losetup --show -f ${BUILD_IMAGES}/${IMAGE_FILE_NAME})"
		IMAGE_LOOP_DEV_BOOT="${IMAGE_LOOP_DEV}p1"
		IMAGE_LOOP_DEV_ROOTFS="${IMAGE_LOOP_DEV}p2"
		sudo partprobe "${IMAGE_LOOP_DEV}"
		echo "Mounting ${IMAGE_LOOP_DEV_BOOT}..."
		sudo mount -o loop "${IMAGE_LOOP_DEV_BOOT}" $BOOT || {
			error_msg "Failed to mount $IMAGE_LOOP_DEV_BOOT!"

			return -1
		}
		echo "Mount ${IMAGE_LOOP_DEV_BOOT} on $BOOT/ OK."
		echo "Mountng ${IMAGE_LOOP_DEV_ROOTFS}..."
		sudo mount -o loop "${IMAGE_LOOP_DEV_ROOTFS}" $ROOTFS || {
			sudo sync
			sudo umount $BOOT
			error_msg "Failed to mount $IMAGE_LOOP_DEV_ROOTFS!"

			return -1
		}
		echo "Mount ${IMAGE_LOOP_DEV_ROOTFS} on $ROOTFS/ OK."
	elif [ "$INSTALL_TYPE" == "EMMC" ]; then
		BOOT_DIR="$ROOTFS/boot"
		echo "Mounting rootfs.img..."
		sudo mount -o loop ${BUILD_IMAGES}/rootfs.img $ROOTFS || {
			error_msg "Failed to mount rootfs.img!"

			return -1
		}
		echo "Mount ${BUILD_IMAGES}/rootfs.img on $ROOTFS/ OK."
	fi

	## [Optional] Mirrors for ubuntu-ports
	if [ -f .khadas-build ]; then
		echo "Using ustc mirrors..."
		sudo cp -a $ROOTFS/etc/apt/sources.list $ROOTFS/etc/apt/sources.list.orig
		sudo sed -i "s/http:\/\/ports.ubuntu.com\/ubuntu-ports\//http:\/\/mirrors.ustc.edu.cn\/ubuntu-ports\//g" $ROOTFS/etc/apt/sources.list
	fi

#	sudo make -C $LINUX_DIR -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- install INSTALL_PATH=${BOOT_DIR}
	install_kernel $(grep "Linux/arm64" $LINUX_DIR/.config | awk  '{print $3}') $LINUX_DIR/arch/arm64/boot/Image $LINUX_DIR/System.map ${BOOT_DIR}
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
		sudo rm aml_autoscript.zip
		sudo zip aml_autoscript.zip aml_autoscript aml_autoscript.txt
		cd -
	fi

	## Update linux modules
	sudo rm -rf $ROOTFS/lib/modules
	sudo make -C $LINUX_DIR -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules_install INSTALL_MOD_PATH=$ROOTFS/
	sudo make -C $LINUX_DIR -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- headers_install INSTALL_HDR_PATH=$ROOTFS/usr/
	## Update linux dtb Image
	## FIXME will use deb package in the future
	if [ "$LINUX" == "4.9" -o "$LINUX" == "mainline" ];then
		if [ "$INSTALL_TYPE" == "SD-USB" ]; then
			sudo mkdir -p $BOOT_DIR/dtb
			sudo cp $LINUX_DIR/arch/arm64/boot/dts/amlogic/*.dtb $BOOT_DIR/dtb
		elif [ "$INSTALL_TYPE" == "EMMC" ]; then
			sudo cp $LINUX_DIR/$LINUX_DTB $BOOT_DIR
			# Backup dtb
			sudo cp $LINUX_DIR/$LINUX_DTB $BOOTDIR/$(basename $LINUX_DTB).old
		fi
	elif [ "$LINUX" == "3.14" ];then
		if [ "$INSTALL_TYPE" == "SD-USB" ]; then
			sudo mkdir -p $BOOT_DIR/dtb
			sudo cp $LINUX_DIR/arch/arm64/boot/dts/*.dtb $BOOT_DIR/dtb
		elif [ "$INSTALL_TYPE" == "EMMC" ]; then
			sudo cp $LINUX_DIR/$LINUX_DTB $BOOT_DIR
			# Backup dtb
			sudo cp $LINUX_DIR/$LINUX_DTB $BOOT_DIR/$(basename $LINUX_DTB).old
		fi
	else
		error_msg "Unsupported linux version:'$LINUX'"
		sudo sync
		sudo umount $ROOTFS
		if [ "$INSTALL_TYPE" == "SD-USB" ]; then
			sudo umount $BOOT
		fi

		return -1
	fi

	sudo cp $LINUX_DIR/arch/arm64/boot/Image $BOOT_DIR

	## linux version
	grep "Linux/arm64" $LINUX_DIR/.config | awk  '{print $3}' > $BUILD_IMAGES/linux-version
	sudo cp -r $BUILD_IMAGES/linux-version $ROOTFS/

	## firstboot initialization: for 'ROOTFS' partition resize
	if [ "$INSTALL_TYPE" == "EMMC" ]; then
		sudo touch $ROOTFS/etc/default/FIRSTBOOT
	fi

	## script executing on chroot
	sudo cp -r archives/filesystem/RUNME_REMOUNT.sh $ROOTFS/

	## Chroot
	if [ "$UBUNTU_ARCH" == "arm64" ]; then
		sudo cp -a /usr/bin/qemu-aarch64-static $ROOTFS/usr/bin/
	elif [ "$UBUNTU_ARCH" == "armhf" ]; then
		sudo cp -a /usr/bin/qemu-arm-static $ROOTFS/usr/bin/
	fi

	sudo mount -o bind /proc $ROOTFS/proc
	sudo mount -o bind /sys $ROOTFS/sys
	sudo mount -o bind /dev $ROOTFS/dev
	sudo mount -o bind /dev/pts $ROOTFS/dev/pts

	while true; do
		read -n1 -p $'\n(A)utorun script, (M)anual chroot or (Q)uit? [a/m/q]' answer
		case $answer in
			[Aa]* )
				echo -e "\nAutorun script."
				sudo chroot $ROOTFS/ bash "/RUNME_REMOUNT.sh" $UBUNTU $INSTALL_TYPE
				break;;
			[Mm]* )
				echo -e "\n\nNOTE: YOU ARE NOW IN THE VIRTUAL TARGET, SETUP ANYTHING YOU WANT."
				echo -e "      TYPE 'exit' TO CONTINUE IF FINISHED.\n"
				sudo chroot $ROOTFS/
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
		cp $ROOTFS/boot/initrd.img $BUILD_IMAGES/initrd.img
		$UTILS_DIR/mkbootimg --kernel $LINUX_DIR/arch/arm64/boot/Image --ramdisk $BUILD_IMAGES/initrd.img -o $BUILD_IMAGES/ramdisk.img
	elif [ "$INSTALL_TYPE" == "SD-USB" ]; then
		sudo cp -r $ROOTFS/boot/* $BOOT_DIR
		sudo rm -rf $ROOTFS/boot/*
	fi

	## Clean up
	sudo rm -f $ROOTFS/boot/initrd.img

	## Unmount to get the rootfs.img
	sudo sync
	sudo umount $ROOTFS/dev/pts
	sudo umount $ROOTFS/dev
	sudo umount $ROOTFS/proc
	sudo umount $ROOTFS/sys
	sudo umount $ROOTFS

	if [ "$INSTALL_TYPE" == "SD-USB" ]; then
		sudo umount $BOOT
		sudo losetup -d "${IMAGE_LOOP_DEV}"
	fi

	trap - INT EXIT TERM

	return 0
}


########################################################
prepare_linux_dtb
prepare_linux_dir
remount_rootfs

echo -e "\nDone."
echo -e "\n`date`"
