PKG_NAME="rkbin"
PKG_VERSION="9ab19cc4adfad92d415e0660ae95c60eac45c2eb"
PKG_SHA256="47005e3a87ceba3a9825b7d44590f349b90f5501f889f0f4c0f050b517574dfb"
PKG_SOURCE_DIR="rkbin-${PKG_VERSION}*"
PKG_SITE="$GITHUB_URL/numbqq/rkbin"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="X86"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Rockchip Firmware and Tool Binarys"
PKG_SOURCE_NAME="rkbin-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"


make_host() {
	# Fixup links
	# For Edge2
	ln -fs bin/rk35/rk3588_ddr_lp4_2112MHz_lp5_2400MHz_v1.20.bin rk3588_ddr.bin
	ln -fs bin/rk35/rk3588_bl31_v1.53.elf rk3588_bl31.elf
	ln -fs bin/rk35/rk3588_bl32_v1.20.bin rk3588_bl32.bin
	ln -fs bin/rk35/rk3588_spl_v1.13.bin rk3588_spl.bin

	# For Edge 2L
	ln -fs bin/rk35/rk3576_ddr_lp4_2112MHz_lp5_2736MHz_v1.10.bin rk3576_ddr.bin
	ln -fs bin/rk35/rk3576_bl31_v1.21.elf rk3576_bl31.elf
	ln -fs bin/rk35/rk3576_bl32_v1.07.bin rk3576_bl32.bin
	ln -fs bin/rk35/rk3576_spl_v1.08.bin rk3576_spl.bin
	## Fix usbplug, replace bin/rk35/rk3576_usbplug_v*.bin with bin/rk35/rk3576_usbplug_edge-2l.bin
	sed -i '/\[CODE472_OPTION\]/,/^$/ s|^Path1=bin\/rk35\/rk3576_usbplug_.*\.bin$|Path1=bin/rk35/rk3576_usbplug_edge-2l.bin|' RKBOOT/RK3576MINIALL.ini
	cp $PKGS_DIR/$PKG_NAME/files/Edge-2L/rk3576_usbplug_edge-2l.bin bin/rk35/
}

