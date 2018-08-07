PKG_NAME="xserver_rk3399"
PKG_VERSION="a7afdd0"
PKG_SHA256="7927dd658a066e5b8a2b9c5a7ac3df8cc2e3f864abf02905b55619ab75085477"
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

