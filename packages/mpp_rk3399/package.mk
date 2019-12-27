PKG_NAME="mpp_rk3399"
PKG_VERSION="8fe8118bd31334603bc3b32f5848d44a0c320521"
PKG_SHA256="88bcc31f57bf6bffc3066306a9911cc25ae45da40043822706dbab77c50e0cd9"
PKG_SOURCE_DIR="mpp_rk3399-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/mpp_rk3399"
PKG_URL="https://github.com/numbqq/mpp_rk3399/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm64 armhf"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Rockchip Media Process Platform deb packages for RK3399"
PKG_SOURCE_NAME="mpp_rk3399-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"

make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mpp
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mpp/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mpp
}

