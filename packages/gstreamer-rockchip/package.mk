PKG_NAME="gstreamer-rockchip"
PKG_VERSION="9f968fff1517a9687fec0d937cd6500e5c52384a"
PKG_SHA256="7688a46e60a27572828509165120a8b8bda85e9f812af703ffbddf5e33929c66"
PKG_SOURCE_DIR="gstreamer-rockchip-${PKG_VERSION}*"
PKG_SITE="$GITHUB_URL/yan-wyb/gstreamer-rockchip"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm64 armhf"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Rockchip Gstreamer Rockchip Process Platform deb packages"
PKG_SOURCE_NAME="gstreamer-rockchip-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"

make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer-rockchip
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer-rockchip/*
	[ -d ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/${KHADAS_BOARD} ] && cp -r ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/${KHADAS_BOARD}/* $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}//gstreamer-rockchip || true
}

