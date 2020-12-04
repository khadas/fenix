PKG_NAME="u-boot-mainline"
PKG_VERSION="0719bf42931033c3109ecc6357e8adb567cb637b"
PKG_SOURCE_DIR="u-boot-$PKG_VERSION"
PKG_SOURCE_NAME="u-boot-$PKG_VERSION.tar.gz"
PKG_SITE="https://github.com/u-boot/u-boot"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_SHA256="6b196b6592fabed060b7c5b1fa05a743f9be131d11389b762b7d0e2beebbd381"
PKG_SHORTDESC="u-boot: Universal Bootloader project"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_NEED_BUILD="YES"

make_target() {

	export PATH=$UBOOT_COMPILER_PATH:$PATH
	make distclean
	make ${UBOOT_DEFCONFIG}
	make -j${NR_JOBS} CROSS_COMPILE="${CCACHE} ${UBOOT_COMPILER}"
}

post_make_target() {

	# add embed uboot khadas logo
	cat u-boot-nodtb.bin u-boot.dtb "$PKGS_DIR/$PKG_NAME/files/splash.bmp.gz" > u-boot.bin

	if [ "$VENDOR" == "Amlogic" ]; then
		# Add firmware
		rm -rf "$BUILD/$PKG_NAME-$PKG_VERSION/fip"
		cp -r "$PKGS_DIR/$PKG_NAME/fip/$KHADAS_BOARD" "$BUILD/$PKG_NAME-$PKG_VERSION/fip"
		cp u-boot.bin fip/bl33.bin
		if [[ "$KHADAS_BOARD" =~ VIM[12] ]]; then
			fip/blx_fix.sh fip/bl30.bin fip/zero_tmp fip/bl30_zero.bin fip/bl301.bin fip/bl301_zero.bin fip/bl30_new.bin bl30
			python fip/acs_tool.pyc fip/bl2.bin fip/bl2_acs.bin fip/acs.bin 0
			fip/blx_fix.sh fip/bl2_acs.bin fip/zero_tmp fip/bl2_zero.bin fip/bl21.bin fip/bl21_zero.bin fip/bl2_new.bin bl2
			fip/aml_encrypt_gxl --bl3enc --input fip/bl30_new.bin
			fip/aml_encrypt_gxl --bl3enc --input fip/bl31.img
			fip/aml_encrypt_gxl --bl3enc --input fip/bl33.bin
			fip/aml_encrypt_gxl --bl2sig --input fip/bl2_new.bin --output fip/bl2.n.bin.sig
			fip/aml_encrypt_gxl --bootmk --output fip/u-boot.bin --bl2 fip/bl2.n.bin.sig --bl30 fip/bl30_new.bin.enc --bl31 fip/bl31.img.enc --bl33 fip/bl33.bin.enc
		elif [[ "$KHADAS_BOARD" =~ VIM[3*] ]]; then
			if [ "$KHADAS_BOARD" == "VIM3" ]; then
				aml_encrypt=aml_encrypt_g12b
			elif [ "$KHADAS_BOARD" == "VIM3L" ]; then
				aml_encrypt=aml_encrypt_g12a
			fi
			fip/blx_fix.sh fip/bl30.bin fip/zero_tmp fip/bl30_zero.bin fip/bl301.bin fip/bl301_zero.bin fip/bl30_new.bin bl30
			fip/blx_fix.sh fip/bl2.bin fip/zero_tmp fip/bl2_zero.bin fip/acs.bin fip/bl21_zero.bin fip/bl2_new.bin bl2
			fip/${aml_encrypt} --bl30sig --input fip/bl30_new.bin --output fip/bl30_new.bin.g12a.enc --level v3
			fip/${aml_encrypt} --bl3sig --input fip/bl30_new.bin.g12a.enc --output fip/bl30_new.bin.enc --level v3 --type bl30
			fip/${aml_encrypt} --bl3sig --input fip/bl31.img --output fip/bl31.img.enc --level v3 --type bl31
			fip/${aml_encrypt} --bl3sig --input fip/bl33.bin --compress lz4 --output fip/bl33.bin.enc --level v3 --type bl33 --compress lz4
			fip/${aml_encrypt} --bl2sig --input fip/bl2_new.bin --output fip/bl2.n.bin.sig
			fip/${aml_encrypt} --bootmk \
				--output fip/u-boot.bin \
				--bl2 fip/bl2.n.bin.sig \
				--bl30 fip/bl30_new.bin.enc \
				--bl31 fip/bl31.img.enc \
				--bl33 fip/bl33.bin.enc \
				--ddrfw1 fip/ddr4_1d.fw \
				--ddrfw2 fip/ddr4_2d.fw \
				--ddrfw3 fip/ddr3_1d.fw \
				--ddrfw4 fip/piei.fw \
				--ddrfw5 fip/lpddr4_1d.fw \
				--ddrfw6 fip/lpddr4_2d.fw \
				--ddrfw7 fip/diag_lpddr4.fw \
				--ddrfw8 fip/aml_ddr.fw \
				--ddrfw9 fip/lpddr3_1d.fw \
				--level v3
		fi
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
