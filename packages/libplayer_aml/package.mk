PKG_NAME="libplayer_aml"
PKG_VERSION="9ade50781955918df66acb3caa56c79d82d71a6c"
PKG_SHA256="41e78617003238855008c2661c6eb2688d94919c91ce1adfe10bda9f4abc39d6"
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
