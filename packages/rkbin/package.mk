PKG_NAME="rkbin"
PKG_VERSION="4c4e34a4cec9ff2ed25ea3a781653db3aeb0ce5c"
PKG_SHA256="9e0702b017e17243bfe3a9db6255ba2265c7423ece535809474e6935af70c592"
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
	ln -fs bin/rk35/rk3588_ddr_lp4_2112MHz_lp5_2736MHz_v1.13.bin rk3588_ddr.bin
	ln -fs bin/rk35/rk3588_bl31_v1.41.elf rk3588_bl31.elf
	ln -fs bin/rk35/rk3588_bl32_v1.14.bin rk3588_bl32.bin
	ln -fs bin/rk35/rk3588_spl_v1.12.bin rk3588_spl.bin
}

