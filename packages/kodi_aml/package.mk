PKG_NAME="kodi_aml"
PKG_VERSION="bcd609d9dab2b2772474b8266a48d9d0a1f619b6"
PKG_SHA256="619aca7b7283a23e2f5d784c6df27d17dac0f62724958ee4cde17614bab684c6"
PKG_SOURCE_DIR="kodi_aml-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/kodi_aml"
PKG_URL="https://github.com/numbqq/kodi_aml/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Amlogic Kodi package"
PKG_SOURCE_NAME="kodi_aml-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="YES"


make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/kodi_aml
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/kodi_aml/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/kodi_aml
}
