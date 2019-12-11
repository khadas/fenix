PKG_NAME="opencv3"
PKG_VERSION="a82b4dbe4ad0de75d4724330fb8fa71e69a54bd8"
PKG_SHA256="e1ea57d4eced969f2bfc00b5518a37bad51bf190a6add27cb6048f2b06f257a0"
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
