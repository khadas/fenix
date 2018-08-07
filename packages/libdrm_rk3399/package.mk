PKG_NAME="libdrm_rk3399"
PKG_VERSION="e84e33f"
PKG_SHA256="32a3f3d9a8a14de4b2b4b9a0dd5f3d3aba5609baef2715de9512def07bf12fc4"
PKG_SOURCE_DIR="libdrm_rk3399-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/libdrm_rk3399"
PKG_URL="https://github.com/numbqq/libdrm_rk3399/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm64 armhf"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Rockchip Userspace Library for DRM RGA device deb packages for RK3399"
PKG_SOURCE_NAME="libdrm_rk3399-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"

make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/libdrm
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/libdrm/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/libdrm
}

