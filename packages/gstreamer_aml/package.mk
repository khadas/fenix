PKG_NAME="gstreamer_aml"
PKG_VERSION="7e4e80864e847943e3efe69726497b9b4099532f"
PKG_SHA256="79f457cebd9d87bbb3b6ebce2b0ada7dcd734f05e1bf3821d84b8d87fa1f6a7f"
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
