PKG_NAME="kodi_s922x"
PKG_VERSION="7e60b15f5b467002f21d6da9fb30dcfda5d26fbb"
PKG_SHA256="108c63b978ce042e02914fd3693707c44590de48ec12332865dbfdb44c79bdee"
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
