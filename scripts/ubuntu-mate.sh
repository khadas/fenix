#!/bin/bash

########################### Parameters ###################################

UBOOT_DEFCONFIG=
LINUX_DTB=
UBUNTU_MATE=
UBOOT_GIT_BRANCH=
LINUX_GIT_BRANCH=

AML_UPDATE_TOOL_CONFIG=

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

## $1 board              <VIM | VIM2>
## $2 ubuntu version     <16.04.2 | 17.04 | 17.10>
## $3 linux version      <4.9 | 3.14>
check_parameters() {
	if [ "$1" == "" ] || [ "$2" == "" ]  || [ "$3" == "" ]; then
		echo "usage: $0 <VIM|VIM2> <16.04.2|17.04|17.10> <4.9|3.14>"
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

## Select ubuntu mate
prepare_ubuntu_mate() {
	ret=0
	case "$UBUNTU" in
		16.04.2)
			UBUNTU_MATE="ubuntu-mate-16.04.2-arm64.tar.gz"
			;;
		17.04)
			UBUNTU_MATE="ubuntu-mate-17.04-arm64.tar.gz"
			;;
		17.10)
			UBUNTU_MATE="artful-mate-arm64.tar.gz"
			;;
		*)
			error_msg $CURRENT_FILE $LINENO "Unsupported ubuntu version:$UBUNTU"
			UBUNTU_MATE=
			ret=-1
	esac

	return $ret
}

## Display parameters
display_parameters() {
	echo ""
	echo "***********************PARAMETERS************************"
	echo "board:                         $KHADAS_BOARD"
	echo "linux version:                 $LINUX"
	echo "ubuntu version:                $UBUNTU"
	echo "uboot configuration:           $UBOOT_DEFCONFIG"
	echo "linux dtb:                     $LINUX_DTB"
	echo "ubuntu mate:                   $UBUNTU_MATE"
	echo "uboot git branch:              $UBOOT_GIT_BRANCH"
	echo "linux git branch:              $LINUX_GIT_BRANCH"
	echo "base directory:                $BASE_DIR"
	echo "project directory:             $PROJECT_DIR"
	echo "khadas directory:              $KHADAS_DIR"
	echo "ubuntu working directory:      $UBUNTU_WORKING_DIR"
	echo "amlogic update tool config:    $AML_UPDATE_TOOL_CONFIG"
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

	install -d ${UBUNTU_WORKING_DIR}/{linux,rootfs,archives/{ubuntu-base,debs,hwpacks,ubuntu-mate},images,scripts}

	cd ${UBUNTU_WORKING_DIR}

	if [ ! -d "utils/.git" ]; then
		##Clone utils.git from Khadas GitHub
		echo "Utils repository dose not exist, clone utils repository('master') from Khadas GitHub..."
		git clone https://github.com/khadas/utils.git
		[ $? != 0 ] && error_msg $CURRENT_FILE $LINENO "Failed to clone 'utils.git'" && return -1
	fi

	cd images/
	if [ ! -d "upgrade/.git" ]; then
		##Clone upgrade.git from Khadas GitHub
		echo "Upgrade repository dose not exist, clone upgrade repository('master') from Khadas GitHub..."
		git clone https://github.com/khadas/upgrade.git
		[ $? != 0 ] && error_msg $CURRENT_FILE $LINENO "Failed to clone 'upgrade.git'" && return -1
	fi

	cd -
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

## Setup ubuntu mate
setup_ubuntu_mate() {
	ret=0
	if [ "$UBUNTU_MATE" == "" ]; then
		error_msg $CURRENT_FILE $LINENO "'UBUNTU_MATE' is empty!"
		return -1
	fi

	cd ${UBUNTU_WORKING_DIR}/archives/ubuntu-mate

	if [ ! -f $UBUNTU_MATE ]; then
		# FIXME
		error_msg $CURRENT_FILE $LINENO "'$UBUNTU_MATE' does not exist, please download it into folder
					'`pwd`' manually, and try again!" && ret=-1
	fi

	cd -

	return $ret
}

## Rootfs
build_rootfs() {
	ret=0
	cd ${UBUNTU_WORKING_DIR}
	dd if=/dev/zero of=images/rootfs.img bs=1M count=0 seek=3400
	sudo mkfs.ext4 -F -L ROOTFS images/rootfs.img
	rm -rf rootfs && install -d rootfs
	sudo mount -o loop images/rootfs.img rootfs
	sudo rm -rf rootfs/lost+found
	# ubuntu-mate
	echo "Extracting ubuntu mate rootfs, please wait..."
	sudo tar -xzf archives/ubuntu-mate/$UBUNTU_MATE -C rootfs/
	# [Optional] Mirrors for ubuntu-ports
	sudo cp -a rootfs/etc/apt/sources.list rootfs/etc/apt/sources.list.orig
	sudo sed -i "s/http:\/\/ports.ubuntu.com\/ubuntu-ports\//http:\/\/mirrors.ustc.edu.cn\/ubuntu-ports\//g" rootfs/etc/apt/sources.list
	# linux modules
	sudo make -C linux/ -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules_install INSTALL_MOD_PATH=../rootfs/
	# copy linux dtb Image to rootfs /boot
	if [ "$LINUX" == "4.9" ];then
		sudo cp linux/arch/arm64/boot/dts/amlogic/$LINUX_DTB rootfs/boot/
	elif [ "$LINUX" == "3.14" ];then
		sudo cp linux/arch/arm64/boot/dts/$LINUX_DTB rootfs/boot/
	else
		error_msg $CURRENT_FILE $LINENO "Unsupported linux version:'$LINUX'"
		ret=-1
	fi
	sudo cp linux/arch/arm64/boot/Image rootfs/boot/
	# linux version
	grep "Linux/arm64" linux/.config | awk  '{print $3}' > images/linux-version
	sudo cp -r images/linux-version rootfs/
	# initramfs
	sudo cp -r archives/filesystem/etc/initramfs-tools/ rootfs/etc/
	# fixup network-manager script
	sudo cp -r archives/filesystem/etc/init.d/khadas-restart-nm.sh rootfs/etc/init.d/khadas-restart-nm.sh
	# WIFI
	sudo mkdir -p rootfs/lib/firmware
	sudo cp -r archives/hwpacks/wlan-firmware/brcm/ rootfs/lib/firmware/
	# Bluetooth
	sudo cp -r archives/hwpacks/bluez/brcm_patchram_plus rootfs/usr/local/bin/
	sudo cp -r archives/hwpacks/bluez/bluetooth-khadas.service rootfs/lib/systemd/system/
	sudo cp -r archives/hwpacks/bluez/bluetooth-khadas.sh rootfs/usr/local/bin/

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
		sudo cp -arf archives/hwpacks/mali/r7p0/lib/arm64/r7p0/m450/*.so* rootfs/usr/lib/
		sudo cp -arf archives/hwpacks/mali/r7p0/lib/arm64/r7p0/m450/*.so* rootfs/usr/lib/aarch64-linux-gnu

		### wayland
		### sudo cp -arf archives/hwpacks/mali/r7p0/lib/arm64/r7p0/m450/wayland/*.so* rootfs/usr/lib/
		### sudo cp -arf archives/hwpacks/mali/r7p0/lib/arm64/r7p0/m450/wayland/*.so* rootfs/usr/lib/aarch64-linux-gnu

		### links
		sudo cp -arf archives/hwpacks/mali/r7p0/lib/*.so* rootfs/usr/lib/
		sudo cp -arf archives/hwpacks/mali/r7p0/lib/*.so* rootfs/usr/lib/aarch64-linux-gnu

		sudo mkdir -p rootfs/usr/lib/pkgconfig/
		sudo cp -arf archives/hwpacks/mali/r7p0/lib/pkgconfig/*.pc rootfs/usr/lib/pkgconfig/

		# Mali m450 framebuffer mode examples
		sudo mkdir -p rootfs/usr/share/arm/
		sudo cp -arf archives/hwpacks/mali/fbdev_examples/$LINUX/lib/* rootfs/usr/lib/
		sudo cp -arf archives/hwpacks/mali/fbdev_examples/$LINUX/opengles_20 rootfs/usr/share/arm/
	fi

	# rc.local
	sudo cp -r archives/filesystem/etc/rc.local rootfs/etc/
	# firstboot initialization: for 'ROOTFS' partition resize
	sudo touch rootfs/etc/default/FIRSTBOOT

	# mkimage tool
	sudo cp ./utils/mkimage-arm64 rootfs/usr/local/bin/mkimage

	## script executing on chroot
	sudo cp -r archives/filesystem/RUNME_mate.sh rootfs/

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
	sudo chroot rootfs/ bash "/RUNME_mate.sh" $UBUNTU

	## Generate ramdisk.img
	cp rootfs/boot/initrd.img images/initrd.img
	./utils/mkbootimg --kernel linux/arch/arm64/boot/Image --ramdisk images/initrd.img -o images/ramdisk.img

	## Logo
	cp archives/logo/logo.img images/

	## Clean up
	sudo rm rootfs/boot/initrd.img

	## Unmount to get the rootfs.img
	sudo sync
	sudo umount rootfs/dev/pts
	sudo umount rootfs/dev
	sudo umount rootfs/proc
	sudo umount rootfs/sys
	sudo umount rootfs

	return $ret
}

## Pack the images to update.img
pack_update_image() {
	cd ${UBUNTU_WORKING_DIR}

	if [ $AML_UPDATE_TOOL_CONFIG == "" ]; then
		error_msg $CURRENT_FILE $LINENO "'AML_UPDATE_TOOL_CONFIG' is empty!"
		return -1
	fi

	echo "Packing update image using config: $AML_UPDATE_TOOL_CONFIG"
	./utils/aml_image_v2_packer -r images/upgrade/$AML_UPDATE_TOOL_CONFIG images/upgrade/ images/update.img
}

###########################################################
start_time=`date +%s`
check_parameters $1 $2 $3      &&
prepare_uboot_configuration    &&
prepare_linux_dtb              &&
prepare_git_branch             &&
prepare_ubuntu_mate            &&
prepare_working_environment    &&
prepare_aml_update_tool_config &&
display_parameters             &&
fixup_dtb_link                 &&
setup_ubuntu_mate              &&
build_uboot                    &&
build_linux                    &&
build_rootfs                   &&
pack_update_image              &&

echo -e "\nDone."
echo -e "\n`date`"

end_time=`date +%s`

time_cal $(($end_time - $start_time))
