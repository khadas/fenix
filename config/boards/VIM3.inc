##########################
## VIM3 common part
##########################
case "$UBOOT" in
	2015.01)
		UBOOT_COMPILER="aarch64-none-elf-"
		UBOOT_COMPILER_PATH="$TOOLCHAINS/gcc-linaro-aarch64-none-elf/bin:$TOOLCHAINS/gcc-linaro-arm-none-eabi/bin"
		UBOOT_DIR="$ROOT/u-boot"
		UBOOT_IMAGE_DIR="$UBOOT_DIR/fip/_tmp"
	;;
	mainline)
		UBOOT_COMPILER="aarch64-elf-"
		UBOOT_COMPILER_PATH="$TOOLCHAINS/gcc-linaro-aarch64-elf/bin"
		UBOOT_DIR="$BUILD/u-boot-mainline-*"
		UBOOT_IMAGE_DIR="$BUILD_IMAGES/u-boot-mainline/$KHADAS_BOARD"
	;;
esac

UBOOT_IMAGE_FILES="u-boot.bin u-boot.bin.sd.bin"

UBOOT_FORCE_REBUILD="yes"

KERNEL_COMPILER="aarch64-linux-gnu-"
KERNEL_COMPILER_PATH="$TOOLCHAINS/gcc-linaro-aarch64-linux-gnu/bin"

case "$LINUX" in
	mainline)
		LINUX_DIR="$BUILD/linux-mainline-*"
		;;
	4.9)
		LINUX_DIR="$ROOT/linux"
		;;
esac

BOOT_SCRIPT_BOARD="s905_autoscript.cmd"
BOOT_SCRIPT_VENDOR="aml_autoscript.txt"
BOOT_INI="aml_boot.ini"

BOOT_ENV_FILE="amlogic_default_env.txt"

####
WIFI_MODEL="Broadcom"

##############################
uboot_custom_postprocess() {
	cd $UBOOT_DIR

	# Cleanup old binaries
	rm -rf ${FIP_BUILD_FOLDER}

#	source fip/check_compile.sh
	source fip/variables.sh "$UBOOT_DIR"
	source fip/lib.sh
	source fip/build_bl2.sh
	source fip/build_bl30.sh
	source fip/build_bl31.sh
	source fip/build_bl32.sh
	source fip/build_bl33.sh
	source fip/build_bl40.sh

	# source uboot pre-build configs
	source ${SOURCE_FILE}

	CUR_SOC=${CONFIG_SYS_SOC}

	if [ "y" == "${CONFIG_NEED_BL32}" ]; then
		BLX_NEEDFUL[3]="true"
	fi

	export_variables

	source ${FIP_FOLDER}${CUR_SOC}/variable_soc.sh

	# source soc package script
	source ${FIP_FOLDER}${CUR_SOC}/build.sh

	#bin_path_parser

	# source configs
	source ${CONFIG_FILE}
	if [ "y" == "${CONFIG_SUPPORT_CUSOTMER_BOARD}" ]; then
		BOARD_DIR="customer/board/${CONFIG_SYS_BOARD}"
	else
		BOARD_DIR="${CONFIG_BOARDDIR}"
	fi

	mkdir -p ${FIP_BUILD_FOLDER}

	cp ${FIP_FOLDER}${CUR_SOC}/bl2.bin $FIP_BUILD_FOLDER
	cp ${FIP_FOLDER}${CUR_SOC}/bl30.bin $FIP_BUILD_FOLDER
	cp ${FIP_FOLDER}${CUR_SOC}/bl31.bin $FIP_BUILD_FOLDER
	cp ${FIP_FOLDER}${CUR_SOC}/bl31.img $FIP_BUILD_FOLDER
#	cp ${FIP_FOLDER}${CUR_SOC}/bl32.bin $FIP_BUILD_FOLDER

	# cp bl33(uboot)
	copy_bl33

	# cp other firmwares(soc related)
	copy_other_soc

	# package final bootloader
	package

	if [ "y" != "${CONFIG_AML_SIGNED_UBOOT}" ]; then
		# copy bootloader to main folder
		mkdir -p ${BUILD_FOLDER}
		cp ${FIP_BUILD_FOLDER}u-boot.bin ${BUILD_FOLDER}u-boot.bin
		cp ${FIP_BUILD_FOLDER}u-boot.bin.encrypt ${BUILD_FOLDER}u-boot.bin.encrypt
		cp ${FIP_BUILD_FOLDER}u-boot.bin.encrypt.efuse ${BUILD_FOLDER}u-boot.bin.encrypt.efuse
		cp ${FIP_BUILD_FOLDER}u-boot.bin.encrypt.sd.bin ${BUILD_FOLDER}u-boot.bin.encrypt.sd.bin
		cp ${FIP_BUILD_FOLDER}u-boot.bin.encrypt.usb.bl2 ${BUILD_FOLDER}u-boot.bin.encrypt.usb.bl2
		cp ${FIP_BUILD_FOLDER}u-boot.bin.encrypt.usb.tpl ${BUILD_FOLDER}u-boot.bin.encrypt.usb.tpl
		cp ${FIP_BUILD_FOLDER}u-boot.bin.sd.bin ${BUILD_FOLDER}u-boot.bin.sd.bin
		cp ${FIP_BUILD_FOLDER}u-boot.bin.usb.bl2 ${BUILD_FOLDER}u-boot.bin.usb.bl2
		cp ${FIP_BUILD_FOLDER}u-boot.bin.usb.tpl ${BUILD_FOLDER}u-boot.bin.usb.tpl

		if [ "y" == "${CONFIG_AML_CRYPTO_IMG}" ]; then
			cp ${FIP_BUILD_FOLDER}boot.img.encrypt ${BUILD_FOLDER}boot.img.encrypt
		fi
	fi

	cd $ROOT
}

## Write u-boot
write_uboot_platform()
{
	dd if=$1/u-boot.bin.sd.bin of=$2 conv=fsync bs=1 count=442 > /dev/null 2>&1
	dd if=$1/u-boot.bin.sd.bin of=$2 conv=fsync bs=512 skip=1 seek=1 > /dev/null 2>&1
}

setup_write_uboot_platform()
{
	if grep -q "ubootpart" /proc/cmdline; then
		local tmp=$(cat /proc/cmdline)
		local ubootpart="${tmp##*ubootpart=}"
		local imagetype="${tmp##*imagetype=}"
		ubootpart="${ubootpart%% *}"
		imagetype="${imagetype%% *}"

		if [ "$imagetype" == "SD-USB" ] || [ "$imagetype" == "EMMC_MBR" ]; then
			[[ -n $ubootpart && $ubootpart != NULL ]] && local part=$(findfs PARTUUID=$ubootpart 2>/dev/null)
			[[ -n $part ]] && local dev=$(lsblk -n -o PKNAME $part 2>/dev/null)
			[[ -n $dev ]] && DEVICE="/dev/$dev"
		elif [ "$imagetype" == "EMMC" ]; then
			# For vendor eMMC image, need to update in u-boot
			DEVICE="VENDOR"
		fi
	fi
}

## Pack image
pack_image_platform() {
    cd ${ROOT}

    info_msg "Image install type: $INSTALL_TYPE"
    if [ "$INSTALL_TYPE" == "EMMC" ]; then
		## Fixup upgrade dtb link
		cd $UPGRADE_DIR/Amlogic
		rm -rf kvim.dtb

		case "$LINUX" in
			4.9)
				ln -fs ../../../linux/$LINUX_DTB kvim.dtb
				ln -fs ../../../u-boot/fip/_tmp/u-boot.bin u-boot.bin
				ln -fs ../../../u-boot/fip/_tmp/u-boot.bin.sd.bin u-boot.bin.sd.bin
				ln -fs ../../../u-boot/fip/_tmp/u-boot.bin.usb.bl2 u-boot.bin.usb.bl2
				ln -fs ../../../u-boot/fip/_tmp/u-boot.bin.usb.tpl u-boot.bin.usb.tpl
				;;
		mainline)
				;;
		esac

		## Fixup platform & package configuration file
		ln -fs package_g12.conf package.conf
		ln -fs platform_g12.conf platform.conf

		cd -

        $UTILS_DIR/aml_image_v2_packer -r $UPGRADE_DIR/Amlogic/package.conf $UPGRADE_DIR/Amlogic $BUILD_IMAGES/${IMAGE_FILE_NAME}
    elif [ "$INSTALL_TYPE" == "SD-USB" ]; then

        IMAGE_LOOP_DEV="$(losetup --show -f ${BUILD_IMAGES}/${IMAGE_FILE_NAME})"
        if [[ -z $IMAGE_LOOP_DEV ]]; then
			error_msg "Unable to find free loop device!"
			return -1
		fi
		partprobe "${IMAGE_LOOP_DEV}"

		check_loop_device "$IMAGE_LOOP_DEV"

		write_uboot_platform ${UBOOT_IMAGE_DIR} ${IMAGE_LOOP_DEV}

        losetup -d "${IMAGE_LOOP_DEV}"
    else
        error_msg "Unsupported install type: '$INSTALL_TYPE'"
        return -1
    fi

    echo ""
	info_msg "IMAGE: ${GREEN}$BUILD_IMAGES/$IMAGE_FILE_NAME ${ENDCOLOR} is ready!"
}

## tweaks for platform
tweaks_platform() {
	echo "#Serial console allow root" >> $ROOTFS_TEMP/etc/securetty
	echo "ttyAML0" >> $ROOTFS_TEMP/etc/securetty

	# Enable services
	eval 'LC_ALL=C LANG=C chroot $ROOTFS_TEMP /bin/bash -c "systemctl --no-reload enable bluetooth-khadas.service fan.service"'

	if [ "$DISTRIB_TYPE" != "server" ] && [ "$LINUX" != "mainline" ]; then
		eval 'LC_ALL=C LANG=C chroot $ROOTFS_TEMP /bin/bash -c "systemctl --no-reload enable panel.service hdmi_resolution.service"'
	fi

	if [ "$LINUX" != "mainline" ]; then
		eval 'LC_ALL=C LANG=C chroot $ROOTFS_TEMP /bin/bash -c "systemctl --no-reload enable camera_isp_3a_server.service"'
	fi

	# Create boot links
	if [ "$INSTALL_TYPE" == "EMMC" ]; then
		eval 'LC_ALL=C LANG=C chroot $ROOTFS_TEMP /bin/bash -c "ln -fs /boot/zImage zImage"'
		eval 'LC_ALL=C LANG=C chroot $ROOTFS_TEMP /bin/bash -c "ln -fs /boot/uInitrd uInitrd"'
		eval 'LC_ALL=C LANG=C chroot $ROOTFS_TEMP /bin/bash -c "ln -fs /boot/dtb/$(basename $LINUX_DTB) dtb.img"'
	else
		# Setup default DTB for SD/USB images
		if [ "$LINUX" == "mainline" ]; then
			eval 'LC_ALL=C LANG=C chroot $ROOTFS_TEMP /bin/bash -c "cp /boot/dtb/amlogic/$(basename $LINUX_DTB) /boot/dtb.img"'
		else
			eval 'LC_ALL=C LANG=C chroot $ROOTFS_TEMP /bin/bash -c "cp /boot/dtb/$(basename $LINUX_DTB) /boot/dtb.img"'
		fi
	fi
}

## Build deb packages for platform
build_deb_packages_platform() {
	if [ "$LINUX" == "4.9" ] && [ "$DISTRIB_RELEASE" == "bionic" ]; then
		info_msg "Building Kodi packages..."
		# FIXME
		# remove build stamp to force build for other arch
		rm -rf $BUILD/.stamps/kodi_aml
		build_package "kodi_aml:target"

		info_msg "Building libplayer_aml packages..."
		# FIXME
		# remove build stamp to force build for other arch
		rm -rf $BUILD/.stamps/libplayer_aml
		build_package "libplayer_aml:target"

		info_msg "Building amremote packages..."
		# FIXME
		# remove build stamp to force build for other arch
		rm -rf $BUILD/.stamps/amremote
		build_package "amremote:target"

		info_msg "Building gstreamer_aml packages..."
		# FIXME
		# remove build stamp to force build for other arch
		rm -rf $BUILD/.stamps/gstreamer_aml
		build_package "gstreamer_aml:target"

		info_msg "Building npu_aml packages..."
		# FIXME
		# remove build stamp to force build for other arch
		rm -rf $BUILD/.stamps/npu_aml
		build_package "npu_aml:target"

		info_msg "Building opencv3 packages..."
		# FIXME
		# remove build stamp to force build for other arch
		rm -rf $BUILD/.stamps/opencv3
		build_package "opencv3:target"

		info_msg "Building edid-decode-deb packages..."
		# FIXME
		# remove build stamp to force build for other arch
		rm -rf $BUILD/.stamps/edid-decode-deb
		build_package "edid-decode-deb:target"
	fi
}

## Install deb packages for platform
install_deb_packages_platform() {
	if [ "$LINUX" == "4.9" ] && [ "$DISTRIB_RELEASE" == "bionic" ]; then

		cd $ROOT
		# Install Kodi in chroot
		info_msg "Installing Kodi packages..."
		install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/kodi_aml/*.deb

		info_msg "Installing libplayer_aml packages..."
		install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/libplayer_aml/*.deb

		info_msg "Installing amremote packages..."
		install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/amremote/*.deb

		info_msg "Installing gstreamer_aml packages..."
		install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml/*.deb

		info_msg "Installing npu_aml packages..."
		install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/npu_aml/*.deb

		info_msg "Installing opencv3 packages..."
		install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/opencv3/*.deb

		# Enable khadas remote
		eval 'LC_ALL=C LANG=C chroot $ROOTFS_TEMP /bin/bash -c "systemctl --no-reload enable amlogic-remotecfg.service"'

		info_msg "Installing edid-decode-deb packages..."
		install_deb_chroot $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/edid-decode-deb/*.deb
	fi
}
