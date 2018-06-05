PKG_NAME="mpp_rk3399"
PKG_VERSION="9fdb566"
PKG_SHA256="42d67cba9c5256602bbb737b4c692804e8aa8c44dd95893fd32bbd42b8401151"
PKG_SOURCE_DIR="mpp_rk3399-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/mpp_rk3399"
PKG_URL="https://github.com/numbqq/mpp_rk3399/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm64 armhf"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Rockchip Media Process Platform deb packages for RK3399"
PKG_SOURCE_NAME="mpp_rk3399-${PKG_VERSION}.tar.gz"
PKG_SHA256=""
PKG_NEED_BUILD="NO"

make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/mpp
	# Remove old debs
	rm -rf $BUILD_DEBS/mpp/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/mpp
}

