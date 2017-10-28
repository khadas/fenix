#!/bin/bash

########################### Parameters ###################################

UBOOT_DEFCONFIG=
LINUX_DTB=
UBUNTU_ROOTFS=
UBOOT_GIT_BRANCH=
LINUX_GIT_BRANCH=

AML_UPDATE_TOOL_CONFIG=

UBUNTU_SERVER_IMAGE_SIZE=700 # MB
UBUNTU_MATE_IMAGE_SIZE=3700 # MB

UBUNTU_TYPE=$1

BASE_DIR="$HOME"
PROJECT_DIR="${BASE_DIR}/project"
KHADAS_DIR="${PROJECT_DIR}/khadas"
UBUNTU_WORKING_DIR="$(dirname "$(dirname "$(readlink -fm "$0")")")"
IMAGE_DIR="${UBUNTU_WORKING_DIR}/images/"
IMAGE_FILE_NAME="KHADAS_${KHADAS_BOARD}_${INSTALL_TYPE}.img"
IMAGE_FILE_NAME=$(echo $IMAGE_FILE_NAME | tr [A-Z] [a-z])
IMAGE_SIZE=

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
## $4 linux version      	<4.9 | 3.14>
## $5 ubuntu architecture   <arm64 | armhf>
## $6 install type          <EMMC | SD-USB>
check_parameters() {
	if [ "$1" == "" ] || [ "$2" == "" ]  || [ "$3" == "" ] || [ "$4" == "" ] || [ "$5" == "" ] || [ "$6" == "" ]; then
		echo "usage: $0 <server|mate> <VIM|VIM2> <16.04.2|17.04|17.10> <4.9|3.14> <arm64|armhf> <EMMC|SD-USB>"
		return -1;
	fi

	return 0
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
		*)
			error_msg $CURRENT_FILE $LINENO "Unsupported linux version:$LINUX"
			LINUX_GIT_BRANCH=
			ret=-1
	esac

	return $ret
}

## Fixup ~/project/khadas/ubuntu/images/upgrade dtb link
fixup_dtb_link() {
	ret=0
	cd ${UBUNTU_WORKING_DIR}/images/upgrade
	rm -rf kvim.dtb

	case "$LINUX" in
		4.9)
			ln -s ../../linux/arch/arm64/boot/dts/amlogic/$LINUX_DTB kvim.dtb
			;;
		3.14)
			ln -s ../../linux/arch/arm64/boot/dts/$LINUX_DTB kvim.dtb
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
	echo "ubuntu type:                   $UBUNTU_TYPE"
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
	echo "image directory:               $IMAGE_DIR"
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

	install -d ${UBUNTU_WORKING_DIR}/{linux,boot,rootfs,archives/{ubuntu-base,debs,hwpacks,ubuntu-mate},images,scripts}

	cd ${UBUNTU_WORKING_DIR}

	if [ ! -d "utils/.git" ]; then
		##Clone utils.git from Khadas GitHub
		echo "Utils repository dose not exist, clone utils repository('master') from Khadas GitHub..."
		git clone https://github.com/khadas/utils.git
		[ $? != 0 ] && error_msg $CURRENT_FILE $LINENO "Failed to clone 'utils.git'" && return -1
	fi

	cd images/
	if [ ! -d "upgrade/.git" ]; then
		##Clone images_upgrade.git from Khadas GitHub
		echo "Upgrade repository dose not exist, clone images_upgrade repository('master') from Khadas GitHub..."
		git clone https://github.com/khadas/images_upgrade.git upgrade
		[ $? != 0 ] && error_msg $CURRENT_FILE $LINENO "Failed to clone 'images_upgrade.git'" && return -1
	fi

	cd -

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
	make $UBOOT_DEFCONFIG
	make -j8 CROSS_COMPILE=aarch64-linux-gnu-

	return $ret
}

## Build Linux
build_linux() {
	ret=0

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
	make ARCH=arm64 kvim_defconfig
	make -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image $LINUX_DTB  modules
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

	if [ "$KHADAS_BOARD" == "VIM" ]; then
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
			sudo cp -arf archives/hwpacks/mali/r7p0/lib/arm64/r7p0/m450/*.so* rootfs/usr/lib/
			sudo cp -arf archives/hwpacks/mali/r7p0/lib/arm64/r7p0/m450/*.so* rootfs/usr/lib/aarch64-linux-gnu
		elif [ "$UBUNTU_ARCH" == "armhf" ]; then
			sudo cp -arf archives/hwpacks/mali/r7p0/lib/eabihf/r7p0/m450/*.so* rootfs/usr/lib/
			sudo cp -arf archives/hwpacks/mali/r7p0/lib/eabihf/r7p0/m450/*.so* rootfs/usr/lib/arm-linux-gnueabihf
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
	fi
}

## Rootfs
build_rootfs() {
	ret=0
	cd ${UBUNTU_WORKING_DIR}

	IMAGE_LINUX_LOADADDR="0x1080000"
	IMAGE_LINUX_VERSION=`head -n 1 linux/include/config/kernel.release | xargs echo -n`
	BOOT_DIR=

	if [ "$INSTALL_TYPE" == "EMMC" ]; then
		BOOT_DIR="rootfs/boot"
		dd if=/dev/zero of=images/rootfs.img bs=1M count=0 seek=$IMAGE_SIZE
		sudo mkfs.ext4 -F -L ROOTFS images/rootfs.img
		rm -rf rootfs && install -d rootfs
		sudo mount -o loop images/rootfs.img rootfs
	elif [ "$INSTALL_TYPE" == "SD-USB" ]; then
		BOOT_DIR="boot"
		IMAGE_SIZE=$((IMAGE_SIZE + 300)) # SD/USB image szie = BOOT(256MB) + ROOTFS
		dd if=/dev/zero of=${IMAGE_DIR}${IMAGE_FILE_NAME} bs=1M count=0 seek=$IMAGE_SIZE
		sudo fdisk "${IMAGE_DIR}${IMAGE_FILE_NAME}" <<EOF
o
n
p
1
2048
524287
a
t
b
n
p
2
524288

p
w

EOF
		IMAGE_LOOP_DEV="$(sudo losetup --show -f ${IMAGE_DIR}${IMAGE_FILE_NAME})"
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
	sudo cp -a rootfs/etc/apt/sources.list rootfs/etc/apt/sources.list.orig
	sudo sed -i "s/http:\/\/ports.ubuntu.com\/ubuntu-ports\//http:\/\/mirrors.ustc.edu.cn\/ubuntu-ports\//g" rootfs/etc/apt/sources.list

	sudo make -C linux/ -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- install INSTALL_PATH=$PWD/${BOOT_DIR}
	if [ "$INSTALL_TYPE" == "SD-USB" ]; then
		sudo ./utils/mkimage -A arm64 -O linux -T kernel -C none -a $IMAGE_LINUX_LOADADDR -e $IMAGE_LINUX_LOADADDR -n linux-$IMAGE_LINUX_VERSION -d $BOOT_DIR/vmlinuz-$IMAGE_LINUX_VERSION $BOOT_DIR/uImage
		sudo cp $BOOT_DIR/uImage $BOOT_DIR/uImag.old
		# Universal multi-boot
		sudo cp archives/filesystem/boot/* $BOOT_DIR
		if [ "$KHADAS_BOARD" == "VIM" ]; then
			sudo cp $BOOT_DIR/boot.ini.vim $BOOT_DIR/boot.ini
			sudo cp $BOOT_DIR/aml_autoscript.txt.vim $BOOT_DIR/aml_autoscript.txt
		elif [ "$KHADAS_BOARD" == "VIM2" ]; then
			sudo cp $BOOT_DIR/boot.ini.vim2 $BOOT_DIR/boot.ini
			sudo cp $BOOT_DIR/aml_autoscript.txt.vim2 $BOOT_DIR/aml_autoscript.txt
		fi
		sudo ./utils/mkimage -A arm64 -O linux -T script -C none -a 0 -e 0 -n "S905 autoscript" -d $BOOT_DIR/s905_autoscript.cmd $BOOT_DIR/s905_autoscript
		sudo ./utils/mkimage -A arm64 -O linux -T script -C none -a 0 -e 0 -n "S912 autoscript" -d $BOOT_DIR/s912_autoscript.cmd $BOOT_DIR/s912_autoscript
		sudo ./utils/mkimage -A arm64 -O linux -T script -C none -a 0 -e 0 -n "AML autoscript" -d $BOOT_DIR/aml_autoscript.txt $BOOT_DIR/aml_autoscript
		cd $BOOT_DIR
		sudo zip aml_autoscript.zip aml_autoscript aml_autoscript.txt
		cd -
	fi

	# linux modules
	sudo make -C linux/ -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules_install INSTALL_MOD_PATH=../rootfs/
	sudo make -C linux/ -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- headers_install INSTALL_HDR_PATH=$PWD/rootfs/usr/

	# copy linux dtb Image to boot folder
	if [ "$LINUX" == "4.9" ];then
		sudo cp linux/arch/arm64/boot/dts/amlogic/$LINUX_DTB $BOOT_DIR
		## Bakup dtb
		sudo cp linux/arch/arm64/boot/dts/amlogic/$LINUX_DTB $BOOT_DIR/$LINUX_DTB.old
	elif [ "$LINUX" == "3.14" ];then
		sudo cp linux/arch/arm64/boot/dts/$LINUX_DTB $BOOT_DIR
		## Backup dtb
		sudo cp linux/arch/arm64/boot/dts/$LINUX_DTB $BOOT_DIR/$LINUX_DTB.old
	else
		error_msg $CURRENT_FILE $LINENO "Unsupported linux version:'$LINUX'"
		ret=-1
	fi
	sudo cp linux/arch/arm64/boot/Image $BOOT_DIR
	# linux version
	grep "Linux/arm64" linux/.config | awk  '{print $3}' > images/linux-version
	sudo cp -r images/linux-version rootfs/
	# initramfs
	sudo cp -r archives/filesystem/etc/initramfs-tools/ rootfs/etc/
	if [ "$UBUNTU_TYPE" == "mate" ]; then
		# fixup network-manager script
		sudo cp -r archives/filesystem/etc/init.d/khadas-restart-nm.sh rootfs/etc/init.d/khadas-restart-nm.sh
	fi
	# WIFI
	sudo mkdir rootfs/lib/firmware
	sudo cp -r archives/hwpacks/wlan-firmware/brcm/ rootfs/lib/firmware/
	# Bluetooth
	sudo cp -r archives/hwpacks/bluez/brcm_patchram_plus-$UBUNTU_ARCH rootfs/usr/local/bin/brcm_patchram_plus
	sudo cp -r archives/hwpacks/bluez/bluetooth-khadas.service rootfs/lib/systemd/system/
	sudo cp -r archives/hwpacks/bluez/bluetooth-khadas.sh rootfs/usr/local/bin/

	# fw_setenv config
	sudo cp archives/filesystem/etc/fw_env.config rootfs/etc/

	# Install Mali driver
	install_mali_driver

	# rc.local
	sudo cp -r archives/filesystem/etc/rc.local rootfs/etc/
	# firstboot initialization: for 'ROOTFS' partition resize
	sudo touch rootfs/etc/default/FIRSTBOOT

	if [ "$INSTALL_TYPE" == "SD-USB" ]; then
		# resize2fs service to resize rootfs for SD/USB image
		sudo cp -r archives/filesystem/lib/systemd/system/resize2fs.service rootfs/lib/systemd/system/
		sudo cp -r archives/filesystem/etc/init.d/resize2fs rootfs/etc/init.d/
		# For SD/USB image use resize2fs.service to resize
		sudo rm rootfs/etc/default/FIRSTBOOT
	fi

	# mkimage tool
	sudo cp ./utils/mkimage-$UBUNTU_ARCH rootfs/usr/local/bin/mkimage

	## script executing on chroot
	sudo cp -r archives/filesystem/RUNME_${UBUNTU_TYPE}.sh rootfs/

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
	sudo chroot rootfs/ bash "/RUNME_${UBUNTU_TYPE}.sh" $UBUNTU $UBUNTU_ARCH $INSTALL_TYPE $UBUNTU_MATE_ROOTFS_TYPE

	## Generate ramdisk.img
	if [ "$INSTALL_TYPE" == "EMMC" ]; then
		cp rootfs/boot/initrd.img images/initrd.img
		./utils/mkbootimg --kernel linux/arch/arm64/boot/Image --ramdisk images/initrd.img -o images/ramdisk.img
	elif [ "$INSTALL_TYPE" == "SD-USB" ]; then
		sudo mv rootfs/boot/uInitrd $BOOT_DIR
		sudo cp $BOOT_DIR/uInitrd $BOOT_DIR/uInitrd.old
	fi

	## Set default dtb.img
	if [ "$KHADAS_BOARD" == "VIM" ]; then
		sudo cp $BOOT_DIR/kvim.dtb $BOOT_DIR/dtb.img
	elif [ "$KHADAS_BOARD" == "VIM2" ]; then
		sudo cp $BOOT_DIR/kvim2.dtb $BOOT_DIR/dtb.img
	fi

	## Logo
	cp archives/logo/logo.img images/

	## Clean up
	sudo rm rootfs/boot/initrd.img

	## Unmount to get the rootfs.img
	sudo sync
	sudo umount rootfs/dev/pts
	sudo umount rootfs/dev
	sudo umount rootfs/proc
	sudo umount rootfs/sys/kernel/security
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
		./utils/aml_image_v2_packer -r images/upgrade/$AML_UPDATE_TOOL_CONFIG images/upgrade/ images/$IMAGE_FILE_NAME
	elif [ "$INSTALL_TYPE" == "SD-USB" ]; then
		sudo dd if=u-boot/fip/u-boot.bin.sd.bin of="${IMAGE_LOOP_DEV}" conv=fsync bs=1 count=442
		sudo dd if=u-boot/fip/u-boot.bin.sd.bin of="${IMAGE_LOOP_DEV}" conv=fsync bs=512 skip=1 seek=1

		sudo losetup -d "${IMAGE_LOOP_DEV}"
	else
		error_msg $CURRENT_FILE $LINENO "Unsupported install type: '$INSTALL_TYPE'"
		return -1
	fi
}

###########################################################
start_time=`date +%s`
check_parameters $@            &&
prepare_uboot_configuration    &&
prepare_linux_dtb              &&
prepare_git_branch             &&
prepare_ubuntu_rootfs          &&
prepare_working_environment    &&
prepare_aml_update_tool_config &&
display_parameters             &&
fixup_dtb_link                 &&
setup_ubuntu_rootfs            &&
build_uboot                    &&
build_linux                    &&
build_rootfs                   &&
pack_update_image              &&

echo -e "\nDone."
echo -e "\n`date`"

end_time=`date +%s`

time_cal $(($end_time - $start_time))
