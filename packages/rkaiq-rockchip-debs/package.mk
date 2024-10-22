PKG_NAME="rkaiq-rockchip-debs"
PKG_VERSION="2893dba713fefd099cc6bee4f589a72219048982"
PKG_SHA256="6f6983640bd684d751f820e884af48c62a79264706a531d9251fec0cfcc1d530"
PKG_SOURCE_DIR="rkaiq-rockchip-debs-${PKG_VERSION}*"
PKG_SITE="$GITHUB_URL/numbqq/rkaiq-rockchip-debs"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="rkaiq-rockchip-debs"
PKG_SOURCE_NAME="rkaiq-rockchip-debs-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"


make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/rkaiq-rockchip-debs
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/rkaiq-rockchip-debs/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/${KHADAS_BOARD}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/rkaiq-rockchip-debs
}
