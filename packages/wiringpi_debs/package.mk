PKG_NAME="wiringpi_debs"
PKG_VERSION="a0ce2225a378e70ddf7f9ee8ccb6404e64f6c327"
PKG_SHA256="16882f39bb9569b07924bba34f589d2f5f9fabb39ae578feb7cac465886b316a"
PKG_SOURCE_DIR="wiringpi_debs-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/wiringpi_debs"
PKG_URL="https://github.com/numbqq/wiringpi_debs/archive/$PKG_VERSION.tar.gz"
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
