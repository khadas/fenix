PKG_NAME="rkaiq-rockchip-debs"
PKG_VERSION="07d3843cca9b2723ac846e1d1cbb85e873d0f098"
PKG_SHA256="c0fadfe926563b6b286272b9c74261197daf1d992d6e4ae71b84289c84ea9bc6"
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
