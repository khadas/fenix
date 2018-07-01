PKG_NAME="libdrm_rk3399"
PKG_VERSION="063ad57"
PKG_SHA256="f30419f509dc2d52f3a05ad3eb96bf7e0fd35c8b9241b65e2730df7eda8f6a6c"
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
	cp xenial/arm64/*.deb $BUILD_DEBS/libdrm
}

