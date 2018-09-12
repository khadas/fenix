PKG_NAME="qt_rk3399"
PKG_VERSION="4db602f"
PKG_SHA256="8f2c47b448e4882094d3e47290b6006ba3cc3978f512b85421ee4e34462113f9"
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
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/qt
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/qt/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/qt
}

