PKG_NAME="libplayer_aml"
PKG_VERSION="09e9998e873e9be4bc156445eb5479483afbe588"
PKG_SHA256="841bd70f46d6cdb4757943594339e4d46886f37ed1a30b47d5dd67ea8bccf6d2"
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
