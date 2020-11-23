PKG_NAME="libplayer_aml"
PKG_VERSION="e58206a06ecf817c4b7f156512d6ab75c0123031"
PKG_SHA256="8021ee928781b7d15571303e0f5cf547f9e5ec1fb669b3f1b4736e084b0c6636"
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
