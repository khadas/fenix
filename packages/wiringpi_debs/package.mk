PKG_NAME="wiringpi_debs"
PKG_VERSION="99c60ae366de1cea09204acdca0ed7f287438a9e"
PKG_SHA256="93a9510d9e1f3e38e3d5a90de7228115ce2f3f7d3feadc51b2c92f0e1017f7a4"
PKG_SOURCE_DIR="wiringpi_debs-${PKG_VERSION}*"
PKG_SITE="$GITHUB_URL/numbqq/wiringpi_debs"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
[[ $DOWNLOAD_MIRROR == china ]] && \
{
PKG_SITE="$GITEE_URL/numbqq/wiringpi_debs"
PKG_URL="$PKG_SITE/repository/archive/$PKG_VERSION.tar.gz"
PKG_SOURCE_DIR="$PKG_NAME"
PKG_SHA256="9775af7f8bcaf79c9b22f26a86edcf4d5fa427e3584de2590e2300f961bb28c4"
}
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
