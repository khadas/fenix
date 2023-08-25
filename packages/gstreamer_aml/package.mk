PKG_NAME="gstreamer_aml"
PKG_VERSION="5df45e36b81c4faf1c6ffde696a1a1a9f8ccd2f1"
PKG_SHA256="913d839b12afd465d92a0112cd2f64f8cd2a6bc7d67695779beaac1ab9af9ac3"
PKG_SOURCE_DIR="gstreamer_aml-${PKG_VERSION}*"
PKG_SITE="$GITHUB_URL/numbqq/gstreamer_aml"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="gstreamer_aml"
PKG_SOURCE_NAME="gstreamer_aml-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"


make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml 2> /dev/null || cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/${KHADAS_BOARD}/${LINUX}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml
}
