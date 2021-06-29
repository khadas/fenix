#!/bin/bash
##########################
## VIM series common part
##########################
case "$UBOOT" in
	2015.01)
		UBOOT_COMPILER="aarch64-none-elf-"
		UBOOT_COMPILER_PATH="$TOOLCHAINS/gcc-linaro-aarch64-none-elf/bin:$TOOLCHAINS/gcc-linaro-arm-none-eabi/bin"
		[ "$UBOOT_VENDOR_DIR" ] && \
		UBOOT_DIR=$(realpath "$UBOOT_VENDOR_DIR")
		UBOOT_IMAGE_DIR="$UBOOT_DIR/fip/_tmp"
	;;
	2019.01)
		UBOOT_COMPILER="aarch64-elf-"
		UBOOT_COMPILER_PATH="$TOOLCHAINS/gcc-linaro-aarch64-elf/bin"
		[ "$UBOOT_VENDOR_DIR" ] && \
		UBOOT_DIR=$(realpath "$UBOOT_VENDOR_DIR")
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

case "$LINUX" in
	mainline)
		KERNEL_COMPILER="aarch64-none-linux-gnu-"
		KERNEL_COMPILER_PATH="$TOOLCHAINS/gcc-arm-aarch64-none-linux-gnu/bin"
		LINUX_DIR="$BUILD/linux-mainline-*"
		;;
	4.9)
		KERNEL_COMPILER="aarch64-linux-gnu-"
		KERNEL_COMPILER_PATH="$TOOLCHAINS/gcc-linaro-aarch64-linux-gnu/bin"
		LINUX_DIR=$(realpath "$LINUX_VENDOR_DIR")
		;;
	5.4)
		KERNEL_COMPILER="aarch64-none-linux-gnu-"
		KERNEL_COMPILER_PATH="$TOOLCHAINS/gcc-arm-aarch64-none-linux-gnu/bin"
		LINUX_DIR=$(realpath "$LINUX_VENDOR_DIR")
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

	# already inside ?!??
	# cd $UBOOT_DIR
	cd $UBOOT_DIR

	# Cleanup old binaries
	# sorry but its undefined everytime !!!????
	#rm -rf ${FIP_BUILD_FOLDER}

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

	# compile fip tools for ddr_parse and map_tool
	prepare_tools > /dev/null 2>&1 || true

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
	dd if="$1/u-boot.bin.sd.bin" of="$2" conv=fsync,notrunc bs=442 count=1 > /dev/null 2>&1
	dd if="$1/u-boot.bin.sd.bin" of="$2" conv=fsync,notrunc bs=512 skip=1 seek=1 > /dev/null 2>&1
}

## Write u-boot for vendor u-boot
write_uboot_platform_ext()
{
	dd if="$1/u-boot.bin" of=/dev/bootloader conv=fsync bs=1 seek=512 > /dev/null 2>&1
	dd if="$1/u-boot.bin" of=/dev/mmcblk0boot0 conv=fsync bs=1 seek=512 > /dev/null 2>&1
	dd if="$1/u-boot.bin" of=/dev/mmcblk0boot1 conv=fsync bs=1 seek=512 > /dev/null 2>&1
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

pack_image_platform_raw() {

	# ABOUT

	# this simple raw image suitable for dd write to eMMC
	# same for Krescue usage
	# simple alternative for amlogic image

	# USAGE
	#
	# INSTALL_TYPE_RAW=yes make
	#
	# INSTALL_TYPE_RAW=yes COMPRESS_IMAGE=yes make

	[ "$INSTALL_TYPE" != "EMMC" ] && return
	[ "$INSTALL_TYPE_RAW" != "yes" ] && return

	info_msg "Simple raw image suitable for dd write -> $IMAGE_FILE_NAME"

	BS=512

	ROOT_OFFSET=0x0b400000
	DTB1_OFFSET=0x02800000
	DTB2_OFFSET=0x02840000
	LOGO_OFFSET=0x07c00000

	PATH_BOOT="$UBOOT_IMAGE_DIR"/u-boot.bin.sd.bin
	PATH_DTB0="$LINUX_DIR/$LINUX_DTB"
	PATH_ROOT="$BUILD_IMAGES/rootfs.img"
	PATH_LOGO="$BUILD_IMAGES/logo.img"

	F="conv=fsync,notrunc status=noxfer"
	F1="$F,none"
	F2="$F,progress"

	IMG="$BUILD_IMAGES/$IMAGE_FILE_NAME"

	rm -rf $IMG

	(
		dd of="$IMG" if=/dev/null    $F1 seek=$((ROOT_OFFSET/BS))
		dd of="$IMG" if="$PATH_BOOT" $F1
		dd of="$IMG" if="$PATH_DTB0" $F1 seek=$((DTB1_OFFSET/BS))
		dd of="$IMG" if="$PATH_DTB0" $F1 seek=$((DTB2_OFFSET/BS))
		dd of="$IMG" if="$PATH_LOGO" $F1 seek=$((LOGO_OFFSET/BS))
		dd of="$IMG" if="$PATH_ROOT" $F2 seek=$((ROOT_OFFSET/BS))
	)
}

pack_image_platform() {

	if [ "$1" == "uboot-image" ]; then
		PACK_UBOOT_IMAGE="yes"
	else
		PACK_UBOOT_IMAGE="no"
	fi

	cd ${ROOT}

	info_msg "Image install type: $INSTALL_TYPE"

	if [ "$INSTALL_TYPE" == "EMMC" ]; then
		## Fixup upgrade dtb link

		#cd $UPGRADE_DIR/Amlogic
		#rm -rf kvim.dtb

		# resolve and check dir
		for UPGRADE_DIR_ in $UPGRADE_DIR; do
		    [ -d "$UPGRADE_DIR_" ] || {
			error_msg "UPGRADE_DIR not exist: $UPGRADE_DIR"
			return 1
		    }
		done
		for UTILS_DIR_ in $UTILS_DIR; do
		    [ -d "$UTILS_DIR_" ] || {
			error_msg "UTILS_DIR not exist: $UTILS_DIR"
			return 1
		    }
		done

		D="$UPGRADE_DIR_"/Amlogic

		case "$UBOOT" in
			2015.01)
				ln -fs "$BUILD_IMAGES/logo.img"              "$D"/logo.img
				ln -fs "$LINUX_DIR/$LINUX_DTB"               "$D"/kvim.dtb
				ln -fs "$UBOOT_IMAGE_DIR"/u-boot.bin         "$D"/u-boot.bin
				ln -fs "$UBOOT_IMAGE_DIR"/u-boot.bin.sd.bin  "$D"/u-boot.bin.sd.bin
				ln -fs "$UBOOT_IMAGE_DIR"/u-boot.bin.usb.bl2 "$D"/u-boot.bin.usb.bl2
				ln -fs "$UBOOT_IMAGE_DIR"/u-boot.bin.usb.tpl "$D"/u-boot.bin.usb.tpl
				;;
			2019.01)
				ln -fs "$BUILD_IMAGES/logo.img"						"$D"/logo.img
				ln -fs "$LINUX_DIR/$LINUX_DTB"						"$D"/kvim.dtb
				ln -fs "$UBOOT_IMAGE_DIR"/u-boot.bin.signed			"$D"/u-boot.bin.signed
				ln -fs "$UBOOT_IMAGE_DIR"/u-boot.bin.sd.bin.signed	"$D"/u-boot.bin.sd.bin.signed
				ln -fs "$UBOOT_IMAGE_DIR"/u-boot.bin.usb.signed		"$D"/u-boot.bin.usb.signed
				;;
			mainline)
				;;
		esac

		## Fixup platform & package configuration file
		ln -fs "$IMAGE_PACKAGE_CONF"  "$D"/package.conf
		ln -fs "$IMAGE_PLATFORM_CONF" "$D"/platform.conf

		## Fixup rootfs.img
		if [ "$PACK_UBOOT_IMAGE" != "yes" ]; then
			ln -fs "$BUILD_IMAGES"/rootfs.img "$D"/rootfs.img
		else
			IMAGE_FILE_NAME="${KHADAS_BOARD}_Uboot_EMMC_${IMAGE_VERSION}.img"
			ln -fs fake-rootfs.img "$D"/rootfs.img
		fi

		#cd - > /dev/null

		$UTILS_DIR/aml_image_v2_packer -r $UPGRADE_DIR/Amlogic/package.conf $UPGRADE_DIR/Amlogic $BUILD_IMAGES/${IMAGE_FILE_NAME}
    elif [ "$INSTALL_TYPE" == "SD-USB" ]; then
		if [ "$PACK_UBOOT_IMAGE" == "yes" ]; then
			IMAGE_FILE_NAME="${KHADAS_BOARD}_Uboot_SD_${IMAGE_VERSION}.img"
			info_msg "Create Uboot SD image..."
			dd if=/dev/zero of=${BUILD_IMAGES}/${IMAGE_FILE_NAME} bs=1M count=0 seek=4 > /dev/null 2>&1
		fi

		write_uboot_platform "$UBOOT_IMAGE_DIR" "$BUILD_IMAGES/$IMAGE_FILE_NAME"
    else
        error_msg "Unsupported install type: '$INSTALL_TYPE'"
        return 1
    fi

    echo ""
	info_msg "IMAGE: ${GREEN}$BUILD_IMAGES/$IMAGE_FILE_NAME ${ENDCOLOR} is ready!"
}
