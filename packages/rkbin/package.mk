PKG_NAME="rkbin"
PKG_VERSION="50f626abcd07bdc663406e00993546a686c77ddc"
PKG_SHA256="5c1811ec2652386a4bc2f78fddb9622e5609dad6207cb7418087b413020c6c63"
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
	ln -fs bin/rk35/rk3588_ddr_lp4_2112MHz_lp5_2736MHz_v1.11.bin rk3588_ddr.bin
	ln -fs bin/rk35/rk3588_bl31_v1.38.elf rk3588_bl31.elf
	ln -fs bin/rk35/rk3588_bl32_v1.13.bin rk3588_bl32.bin
	ln -fs bin/rk35/rk3588_spl_v1.12.bin rk3588_spl.bin
}

