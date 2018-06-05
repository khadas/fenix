PKG_NAME="libdrm_rk3399"
PKG_VERSION="f4ce3b4"
PKG_SHA256="7c9376a3880f7a630d29f78514057b2c0dc7b2b7e2d558478bd627adbc2fa9b7"
PKG_SOURCE_DIR="libdrm_rk3399-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/libdrm_rk3399"
PKG_URL="https://github.com/numbqq/libdrm_rk3399/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm64 armhf"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Rockchip Userspace Library for DRM RGA device deb packages for RK3399"
PKG_SOURCE_NAME="libdrm_rk3399-${PKG_VERSION}.tar.gz"
PKG_SHA256=""
PKG_NEED_BUILD="NO"

make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/libdrm
	# Remove old debs
	rm -rf $BUILD_DEBS/libdrm/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/libdrm
}

