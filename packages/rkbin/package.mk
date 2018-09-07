PKG_NAME="rkbin"
PKG_VERSION="b789f81"
PKG_SHA256="9fffd99eb5efa7a6cf0b1f3ac4e6b1e2cfe04b6975eb03884c7985cc8b4a5997"
PKG_SOURCE_DIR="rkbin-${PKG_VERSION}*"
PKG_SITE="https://github.com/rockchip-linux/rkbin"
PKG_URL="https://github.com/rockchip-linux/rkbin/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="X86"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Rockchip Firmware and Tool Binarys"
PKG_SOURCE_NAME="rkbin-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"


make_host() {
	chmod +x firmware_merger
	# Fixup links
	ln -fs bin/rk33/rk3399_ddr_800MHz_v1.14.bin rk3399_ddr.bin
	ln -fs bin/rk33/rk3399_miniloader_spinor_v1.14.bin rk3399miniloaderall_spi.bin
	ln -fs bin/rk33/rk3399_miniloader_v1.15.bin rk3399miniloaderall.bin
}

