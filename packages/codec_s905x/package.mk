PKG_NAME="codec_s905x"
PKG_VERSION="551884c"
PKG_SHA256="c54b3f2601de05ad4a60847e7635c884c1d9825ab8cc9a3aae99c19a29111be4"
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
	mkdir -p $BUILD_DEBS/codec_s905x
	# Remove old debs
	rm -rf $BUILD_DEBS/codec_s905x/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/codec_s905x
}
