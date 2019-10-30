PKG_NAME="opencv3"
PKG_VERSION="d6bf3f8647acf00cad479220e9b940290214fa80"
PKG_SHA256="8c61db734307066e90c54141373b89cc9eb7210fa7ebf36ebe2c7f0ac88f6aba"
PKG_SOURCE_DIR="opencv-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/opencv3"
PKG_URL="https://github.com/numbqq/opencv3/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="OpenCV3"
PKG_SOURCE_NAME="opencv3-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="YES"


make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/opencv3
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/opencv3/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/opencv3
}
