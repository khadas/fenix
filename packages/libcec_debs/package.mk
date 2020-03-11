PKG_NAME="libcec_debs"
PKG_VERSION="d1de72eb00eefd22b18996111b2a11d93e8c5bdd"
PKG_SHA256="f02e4dddb25d156593e6063183f204816de00983b0f9fdf3af9c140ed0556a37"
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

