PKG_NAME="codec_s905x"
PKG_VERSION="31dd2f44b5177ca4fb04c940484cd92a704c4d7d"
PKG_SHA256="32a939c830046cf2a6b598bff33d2e9ee1e8f304762adb91307cbe16191fd776"
PKG_SOURCE_DIR="codec_s905x-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/codec_s905x"
PKG_URL="https://github.com/numbqq/codec_s905x/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="libamcodec: Interface library for Amlogic media codecs"
PKG_SOURCE_NAME="codec_s905x-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="YES"


make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/codec_s905x
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/codec_s905x/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/codec_s905x
}
