PKG_NAME="gstreamer_aml"
PKG_VERSION="12dbc134a270fe81faa1bc1643468aeb2f66b3b5"
PKG_SHA256="d659ba712db2e6aee59c612e8f4ff3f2c14b232e87f865037d582052e557e5c5"
PKG_SOURCE_DIR="gstreamer_aml-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/gstreamer_aml"
PKG_URL="https://github.com/numbqq/gstreamer_aml/archive/$PKG_VERSION.tar.gz"
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
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer_aml
}
