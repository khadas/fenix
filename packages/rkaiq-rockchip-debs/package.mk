PKG_NAME="rkaiq-rockchip-debs"
PKG_VERSION="b52c826688102ed15e0005c15e45d3d197b89074"
PKG_SHA256="1239528cc30a2bda427ab40bcb993240d1f3ce29312e6b19c11e62f00f9896e9"
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
