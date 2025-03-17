PKG_NAME="rkbin"
PKG_VERSION="2c1be1054e86338285309ecc20fa61fc15fd5437"
PKG_SHA256="9394e57f508e92bdeb1faa00a96957e31d0f23f705584d507253fc49f38524f1"
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
	ln -fs bin/rk35/rk3588_ddr_lp4_2112MHz_lp5_2400MHz_v1.18.bin rk3588_ddr.bin
	ln -fs bin/rk35/rk3588_bl31_v1.48.elf rk3588_bl31.elf
	ln -fs bin/rk35/rk3588_bl32_v1.19.bin rk3588_bl32.bin
	ln -fs bin/rk35/rk3588_spl_v1.13.bin rk3588_spl.bin
}

