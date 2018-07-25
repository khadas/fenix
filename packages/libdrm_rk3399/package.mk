PKG_NAME="libdrm_rk3399"
PKG_VERSION="96f92f3"
PKG_SHA256="5fe4a6b5d5fea7886a771e6db711bf030d87cdff65d7be4cafbc7973b1da7e62"
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
	mkdir -p $BUILD_DEBS/libdrm
	# Remove old debs
	rm -rf $BUILD_DEBS/libdrm/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/libdrm
}

