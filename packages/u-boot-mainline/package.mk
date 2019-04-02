PKG_NAME="u-boot-mainline"
PKG_VERSION="ee168783ae889cf449cee36cc1e51e108a210ed4" # 2019.01-rc1
PKG_SHA256="e42a01fe79b0fb749d83fe00c9dc0d551b01c68adf3ab696b5475a02fdc1d2a8"
PKG_SOURCE_DIR="u-boot-${PKG_VERSION}*"
PKG_SITE="https://github.com/u-boot/u-boot"
PKG_URL="https://github.com/u-boot/u-boot/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="u-boot: Universal Bootloader project"
PKG_SOURCE_NAME="u-boot-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="YES"


make_target() {

	export PATH=$UBOOT_COMPILER_PATH:$PATH
	make distclean
	make ${UBOOT_DEFCONFIG}
	make -j${NR_JOBS} CROSS_COMPILE=${UBOOT_COMPILER}
}

post_make_target() {
	if [ "$VENDOR" == "Amlogic" ]; then
		# Add firmware
		rm -rf $BUILD/$PKG_NAME-$PKG_VERSION/fip
		cp -r $PKGS_DIR/$PKG_NAME/fip/$KHADAS_BOARD $BUILD/$PKG_NAME-$PKG_VERSION/fip
		cp u-boot.bin fip/bl33.bin
		fip/blx_fix.sh fip/bl30.bin fip/zero_tmp fip/bl30_zero.bin fip/bl301.bin fip/bl301_zero.bin fip/bl30_new.bin bl30
		python fip/acs_tool.pyc fip/bl2.bin fip/bl2_acs.bin fip/acs.bin 0
		fip/blx_fix.sh fip/bl2_acs.bin fip/zero_tmp fip/bl2_zero.bin fip/bl21.bin fip/bl21_zero.bin fip/bl2_new.bin bl2
		fip/aml_encrypt_gxl --bl3enc --input fip/bl30_new.bin
		fip/aml_encrypt_gxl --bl3enc --input fip/bl31.img
		fip/aml_encrypt_gxl --bl3enc --input fip/bl33.bin
		fip/aml_encrypt_gxl --bl2sig --input fip/bl2_new.bin --output fip/bl2.n.bin.sig
		fip/aml_encrypt_gxl --bootmk --output fip/u-boot.bin --bl2 fip/bl2.n.bin.sig --bl30 fip/bl30_new.bin.enc --bl31 fip/bl31.img.enc --bl33 fip/bl33.bin.enc
	elif [ "$VENDOR" == "Rockchip" ]; then
		if [[ $(type -t uboot_custom_postprocess) == function ]]; then
			uboot_custom_postprocess
		fi
	fi
}

makeinstall_target() {
	mkdir -p $BUILD_IMAGES/$PKG_NAME/$KHADAS_BOARD
	rm -rf $BUILD_IMAGES/$PKG_NAME/$KHADAS_BOARD/*

	cd $BUILD/$PKG_NAME-$PKG_VERSION

	if [ "$VENDOR" == "Amlogic" ]; then
		cp fip/u-boot.bin $BUILD_IMAGES/$PKG_NAME/$KHADAS_BOARD
		cp fip/u-boot.bin.sd.bin $BUILD_IMAGES/$PKG_NAME/$KHADAS_BOARD
	elif [ "$VENDOR" == "Rockchip" ]; then
		cp idbloader.img $BUILD_IMAGES/$PKG_NAME/$KHADAS_BOARD
		cp uboot.img $BUILD_IMAGES/$PKG_NAME/$KHADAS_BOARD
		cp trust.img $BUILD_IMAGES/$PKG_NAME/$KHADAS_BOARD
	fi

}
