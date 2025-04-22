PKG_NAME="gstreamer-rockchip-debs"
PKG_VERSION="9866aec041b2ebbed2769ff2c6c219b65f4966b7"
PKG_SHA256="354f5c72688a98b7323b2c11989147fc163076d9a9042d9ae9dad630a652c4af"
PKG_SOURCE_DIR="gstreamer-rockchip-debs-${PKG_VERSION}*"
PKG_SITE="$GITHUB_URL/numbqq/gstreamer-rockchip-debs"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm64 armhf"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Rockchip Gstreamer deb packages"
PKG_SOURCE_NAME="gstreamer-rockchip-debs-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"

make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer-rockchip-debs
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer-rockchip-debs/*
	[ -d ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/${KHADAS_BOARD} ] && cp -rL ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/${KHADAS_BOARD}/* $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer-rockchip-debs || true
}

