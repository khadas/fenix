PKG_NAME="kodi_s922x"
PKG_VERSION="bcd609d9dab2b2772474b8266a48d9d0a1f619b6"
PKG_SHA256="a196f8eb44473185c9cfaf016f908587db350bbe57a2def83c172c915bcb8d6a"
PKG_SOURCE_DIR="kodi_s922x-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/kodi_s922x"
PKG_URL="https://github.com/numbqq/kodi_s922x/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Amlogic S922X Kodi package"
PKG_SOURCE_NAME="kodi_s922x-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="YES"


make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/kodi_s922x
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/kodi_s922x/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/kodi_s922x
}
