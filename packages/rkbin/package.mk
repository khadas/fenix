PKG_NAME="rkbin"
PKG_VERSION="9fc33aee92908b538ca6687550be437415efae8e"
PKG_SHA256="f20a2fb913b39854dba0e26a88945730ba95ba264b185c7fe1b9617fff2338c8"
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
	ln -fs bin/rk33/rk3399_ddr_800MHz_v1.19.bin rk3399_ddr.bin
	ln -fs bin/rk33/rk3399_miniloader_spinor_v1.14.bin rk3399miniloaderall_spi.bin
	ln -fs bin/rk33/rk3399_miniloader_v1.19.bin rk3399miniloaderall.bin
}

