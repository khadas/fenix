PKG_NAME="rkbin"
PKG_VERSION="4f346d31159fc3414be5f7cc4880b9af7ae219d5"
PKG_SHA256="91e078e8a848e15914b08f9a2af73858976c2e5f7eb607a363ff169df1822dc0"
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

