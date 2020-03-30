PKG_NAME="libcec_debs"
PKG_VERSION="424ffb4f0adec2fc022998d09c41e8f609dd6833"
PKG_SHA256="d2a2c050a835c3a2e00bec724e53b693f72c834e6ff6be19f6e84544f8cacd6e"
PKG_SOURCE_DIR="libcec_debs-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/libcec_debs"
PKG_URL="https://github.com/numbqq/libcec_debs/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm64 armhf"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Patched LibCEC"
PKG_SOURCE_NAME="libcec_debs-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"

make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/libcec
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/libcec/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/libcec
}

