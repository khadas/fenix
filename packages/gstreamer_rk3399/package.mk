PKG_NAME="gstreamer_rk3399"
PKG_VERSION="ee9ee0d"
PKG_SHA256="15e2403b789aeacee7b7433b7dff3582bd30b7acdd5f5e1ee9796a0c46921e6b"
PKG_SOURCE_DIR="gstreamer_rk3399-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/gstreamer_rk3399"
PKG_URL="https://github.com/numbqq/gstreamer_rk3399/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm64 armhf"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Rockchip Gstreamer hardware encoder/decoder plugins deb packages for RK3399"
PKG_SOURCE_NAME="gstreamer_rk3399-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"

make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer
}

