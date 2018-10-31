PKG_NAME="u-boot-mainline"
PKG_VERSION="3ae192c2a4d52a755031e93fa6cc3a31ba90f29f"
PKG_SHA256="70621e8164009f08bec05f638858e2e8f77fd9ce31abf8e1b591e1ae6ae98572"
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
	# Add firmware
	rm -rf $BUILD/$PKG_NAME-$PKG_VERSION/fip
	cp -r $PKGS_DIR/$PKG_NAME/fip/$KHADAS_BOARD $BUILD/$PKG_NAME-$PKG_VERSION/fip
	cp u-boot.bin fip/bl33.bin
	fip/blx_fix.sh fip/bl30.bin fip/zero_tmp fip/bl30_zero.bin fip/bl301.bin fip/bl301_zero.bin fip/bl30_new.bin bl30
	fip/acs_tool.pyc fip/bl2.bin fip/bl2_acs.bin fip/acs.bin 0
	fip/blx_fix.sh fip/bl2_acs.bin fip/zero_tmp fip/bl2_zero.bin fip/bl21.bin fip/bl21_zero.bin fip/bl2_new.bin bl2
	fip/aml_encrypt_gxl --bl3enc --input fip/bl30_new.bin
	fip/aml_encrypt_gxl --bl3enc --input fip/bl31.img
	fip/aml_encrypt_gxl --bl3enc --input fip/bl33.bin
	fip/aml_encrypt_gxl --bl2sig --input fip/bl2_new.bin --output fip/bl2.n.bin.sig
	fip/aml_encrypt_gxl --bootmk --output fip/u-boot.bin --bl2 fip/bl2.n.bin.sig --bl30 fip/bl30_new.bin.enc --bl31 fip/bl31.img.enc --bl33 fip/bl33.bin.enc
}

makeinstall_target() {
	mkdir -p $BUILD_IMAGES/$PKG_NAME
	cp fip/u-boot.bin $BUILD_IMAGES/$PKG_NAME
	cp fip/u-boot.bin.sd.bin $BUILD_IMAGES/$PKG_NAME
}
