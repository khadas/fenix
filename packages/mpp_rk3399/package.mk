PKG_NAME="mpp_rk3399"
PKG_VERSION="9d6fb38"
PKG_SHA256="d774425917d30ce00178228b056e7f0980714895b33421458c918996bbd84cd5"
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

