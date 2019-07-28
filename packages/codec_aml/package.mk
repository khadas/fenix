PKG_NAME="codec_aml"
PKG_VERSION="31dd2f44b5177ca4fb04c940484cd92a704c4d7d"
PKG_SHA256="0f0e5c06c254a4726d54c0a7304f8e2c92df99aeb2f4516a1b3a74899dd7c615"
PKG_SOURCE_DIR="codec_aml-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/codec_aml"
PKG_URL="https://github.com/numbqq/codec_aml/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="libamcodec: Interface library for Amlogic media codecs"
PKG_SOURCE_NAME="codec_aml-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="YES"


make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/codec_aml
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/codec_aml/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/codec_aml
}
