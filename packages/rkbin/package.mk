PKG_NAME="rkbin"
PKG_VERSION="612e733e7ea847d9a7358c27d16443ddc8d77ad8"
PKG_SHA256="d227f05bc1838a711caf7ab8ca59ab0650a73ed315b7cd64b3ba46b265e9e914"
PKG_SOURCE_DIR="rkbin-${PKG_VERSION}*"
PKG_SITE="$GITHUB_URL/rockchip-linux/rkbin"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="X86"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Rockchip Firmware and Tool Binarys"
PKG_SOURCE_NAME="rkbin-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"


make_host() {
	# Fixup links
	# For Edge2
	ln -fs bin/rk35/rk3588_ddr_lp4_2112MHz_lp5_2736MHz_v1.07.bin rk3588_ddr.bin
	ln -fs bin/rk35/rk3588_bl31_v1.22.elf rk3588_bl31.elf
	ln -fs bin/rk35/rk3588_bl32_v1.09.bin rk3588_bl32.bin
	ln -fs bin/rk35/rk3588_spl_v1.11.bin rk3588_spl.bin
}

