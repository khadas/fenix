PKG_NAME="wiringpi_debs"
PKG_VERSION="633fca195bfe4811b174783c4a29e7fb1d6847e5"
PKG_SHA256="685c463cf533d9fcdbfd54d00a3ba740d68de8613b8d270bd7b7cc82c4b774df"
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
