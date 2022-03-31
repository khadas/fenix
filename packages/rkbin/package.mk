PKG_NAME="rkbin"
PKG_VERSION="750302a720d6074ead976a8822ed38c7bdd341bf"
PKG_SHA256="581aee16d7fad7c0472522c10e3ddb82429918109c76dedaabd61931f7606bb2"
PKG_SOURCE_DIR="rkbin-${PKG_VERSION}*"
PKG_SITE="$GITHUB_URL/numbqq/rkbin"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="X86"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Rockchip Firmware and Tool Binarys"
PKG_SOURCE_NAME="rkbin-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"


make_host() {
#	chmod +x firmware_merger
	# Fixup links
	#For Edge
	ln -fs bin/rk33/rk3399_ddr_800MHz_v1.24.bin rk3399_ddr.bin
	ln -fs bin/rk33/rk3399_miniloader_spinor_v1.14.bin rk3399miniloaderall_spi.bin
	ln -fs bin/rk33/rk3399_miniloader_v1.24.bin rk3399miniloaderall.bin
	# For Edge2
	ln -fs bin/rk35/rk3588_ddr_lp4_2112MHz_lp5_2736MHz_v1.04.bin rk3588_ddr.bin
	ln -fs bin/rk35/rk3588_bl31_v1.12.elf rk3588_bl31.elf
	ln -fs bin/rk35/rk3588_bl32_v1.06.bin rk3588_bl32.bin
	ln -fs bin/rk35/rk3588_spl_v1.06.bin rk3588_spl.bin
}

