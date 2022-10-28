PKG_NAME="wiringpi_debs"
PKG_VERSION="4595dc3001af98a5d0ac12cee45cc03d2c510213"
PKG_SHA256="0bcb286966412dbf09c879e29d996944782ba171b4635d0ae5b7873fa14ce097"
PKG_SOURCE_DIR="wiringpi_debs-${PKG_VERSION}*"
PKG_SITE="$GITHUB_URL/numbqq/wiringpi_debs"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="WiringPi"
PKG_SOURCE_NAME="wiringpi_debs-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="YES"


make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/wiringpi_debs
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/wiringpi_debs/*
	if [ -d ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/ ]; then
		cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/wiringpi_debs
	fi
}
