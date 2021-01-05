PKG_NAME="libplayer_aml"
PKG_VERSION="d30acd81475dd4a20547630eede887d42b2b0479"
PKG_SHA256="39503b2d00a6eae6cf5d824aa436ee0350be889bf0afe797dfc353862f283748"
PKG_SOURCE_DIR="libplayer_aml-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/libplayer_aml"
PKG_URL="https://github.com/numbqq/libplayer_aml/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Interface library for Amlogic media codecs."
PKG_SOURCE_NAME="libplayer_aml-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"


make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/libplayer_aml
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/libplayer_aml/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/libplayer_aml
}
