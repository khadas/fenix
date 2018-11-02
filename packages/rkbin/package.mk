PKG_NAME="rkbin"
PKG_VERSION="0a6c7c6966a60093a395d094f05dbc5facc6df06"
PKG_SHA256="2980d3bfeb48e46058b74f1245df22e589926abe5db8cb23d195a23fdd4f6341"
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
	ln -fs bin/rk33/rk3399_ddr_800MHz_v1.15.bin rk3399_ddr.bin
	ln -fs bin/rk33/rk3399_miniloader_spinor_v1.14.bin rk3399miniloaderall_spi.bin
	ln -fs bin/rk33/rk3399_miniloader_v1.15.bin rk3399miniloaderall.bin
}

