PKG_NAME="rkbin_edge1"
PKG_VERSION="5aa9a92b5652d37b323c870329103e120dfc8d87"
PKG_SHA256="2b8f817e90ce623bf2cae5e6249f14ffc7ac9991e1e44b9ad6b43ca34c57663c"
PKG_SOURCE_DIR="rkbin-${PKG_VERSION}*"
PKG_SITE="$GITHUB_URL/rockchip-linux/rkbin"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="X86"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Rockchip Firmware and Tool Binarys"
PKG_SOURCE_NAME="rkbin-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"


make_host() {
	chmod +x firmware_merger
	# Fixup links
	ln -fs bin/rk33/rk3399_ddr_800MHz_v1.24.bin rk3399_ddr.bin
	ln -fs bin/rk33/rk3399_miniloader_spinor_v1.14.bin rk3399miniloaderall_spi.bin
	ln -fs bin/rk33/rk3399_miniloader_v1.24.bin rk3399miniloaderall.bin
}

