PKG_NAME="kodi_aml"
PKG_VERSION="4cc4f5cc0bcb470dfcc3f3ff7872c40dc4a7c579"
PKG_SHA256="652b7eb88b3a667db91d9b7f33529bd8c8bb873c65bbd201659b90b2e6aa14c6"
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
