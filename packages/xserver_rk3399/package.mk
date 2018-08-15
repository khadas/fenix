PKG_NAME="xserver_rk3399"
PKG_VERSION="e36d8e2"
PKG_SHA256="50c4e071b71c357638504896baeeae19959ac2a1b725c80e36c09fb35bc76e77"
PKG_SOURCE_DIR="xserver_rk3399-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/xserver_rk3399"
PKG_URL="https://github.com/numbqq/xserver_rk3399/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm64 armhf"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Rockchip xserver deb packages for RK3399"
PKG_SOURCE_NAME="xserver_rk3399-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"

make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/xserver
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/xserver/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/xserver
}

