PKG_NAME="codec_s905x"
PKG_VERSION="8841761"
PKG_SHA256="a22a1e61e7bcdb9f900b4f9defd547c4848797f6f2b13acf06a2ccdcb5553aef"
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
	cp xenial/arm64/*.deb $BUILD_DEBS/codec_s905x
}
