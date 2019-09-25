PKG_NAME="opencv3"
PKG_VERSION="72194bab45cbe1417f9ca706e48779cdafa198d3"
PKG_SHA256="203cd20fe955454e82f5fedc8f1ee5d70fa7b1411cb1f0e268a81b67046212e7"
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
