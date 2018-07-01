PKG_NAME="qt_rk3399"
PKG_VERSION="4db602f"
PKG_SHA256="9ec5cc0d2a1d6cf46fcc42e49ea0292a27a3537ad14afbd3308dddfeab52eff1"
PKG_SOURCE_DIR="qt_rk3399-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/qt_rk3399"
PKG_URL="https://github.com/numbqq/qt_rk3399/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm64 armhf"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Rockchip Video Player for vcodec driver deb packages for RK3399"
PKG_SOURCE_NAME="qt_rk3399-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"

make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/qt
	# Remove old debs
	rm -rf $BUILD_DEBS/qt/*
	cp xenial/arm64/*.deb $BUILD_DEBS/qt
}

