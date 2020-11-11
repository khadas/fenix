PKG_NAME="wiringpi_debs"
PKG_VERSION="1349493e70e4660ebdb98026526db12ff14670d1"
PKG_SHA256="5264814623d1a1bb1fb5ed649d5b714bb1507190290c8df6c1e6aa08116ae144"
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
