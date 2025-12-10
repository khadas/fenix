PKG_NAME="gstreamer_aml"
PKG_VERSION="510668a3de191d496579edbf0cadaaff797e708d"
PKG_SHA256="6fe8cb75787ba6b87ba32d99fd2319a018be0e1e1ecf8ee726fde402a582ba80"
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
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml 2> /dev/null || \
	cp -rf ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/${KHADAS_BOARD}/${LINUX}/* $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml
}
