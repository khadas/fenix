PKG_NAME="rkbin"
PKG_VERSION="1f782f6ac8a08e4dde2867998d155f455d93e8d4"
PKG_SHA256="e9791d22a703ca8bda61b3bcfa2026c0cc685596e8023d8444f966810145146f"
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
	ln -fs bin/rk33/rk3399_ddr_800MHz_v1.17.bin rk3399_ddr.bin
	ln -fs bin/rk33/rk3399_miniloader_spinor_v1.14.bin rk3399miniloaderall_spi.bin
	ln -fs bin/rk33/rk3399_miniloader_v1.15.bin rk3399miniloaderall.bin
}

