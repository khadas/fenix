PKG_NAME="wiringpi_debs"
PKG_VERSION="030c2bec94aa43661c5f0a08b4ff79645f206614"
PKG_SHA256="147a1cb194651ecbd3d51cad82c70e27df65a082c09d10194134e5139ed521eb"
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
