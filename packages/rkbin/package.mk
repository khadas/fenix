PKG_NAME="rkbin"
PKG_VERSION="31cb97291700d408f38ba7a1dc67265672daea6b"
PKG_SHA256="c059a1883e7a364be6c9cfb65a37c8d4456a85402bc4b4de4dda3751e415a0f4"
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
	ln -fs bin/rk35/rk3588_ddr_lp4_2112MHz_lp5_2400MHz_v1.17.bin rk3588_ddr.bin
	ln -fs bin/rk35/rk3588_bl31_v1.46.elf rk3588_bl31.elf
	ln -fs bin/rk35/rk3588_bl32_v1.16.bin rk3588_bl32.bin
	ln -fs bin/rk35/rk3588_spl_v1.13.bin rk3588_spl.bin
}

