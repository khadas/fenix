PKG_NAME="pkg-aml-kodi"
PKG_VERSION="1a86ba4"
PKG_SOURCE_DIR="pkg-aml-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/pkg-aml"
PKG_URL="https://github.com/numbqq/pkg-aml/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Amlogic Kodi package"
PKG_SOURCE_NAME="pkg-aml-kodi-${PKG_VERSION}.tar.gz"
PKG_SHA256=""
PKG_NEED_BUILD="YES"


make_target() {
	# pack
	cd ..
	cp -r ${PKG_NAME}-${PKG_VERSION} ${PKG_NAME}_${VERSION}_${DISTRIB_ARCH}
	rm -rf ${PKG_NAME}_${VERSION}_${DISTRIB_ARCH}/.fenix-unpack
	dpkg -b ${PKG_NAME}_${VERSION}_${DISTRIB_ARCH}
	rm -rf ${PKG_NAME}_${VERSION}_${DISTRIB_ARCH}
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS
	# Remove old debs
	rm -rf $BUILD_DEBS/${PKG_NAME}_*.deb
	mv ${PKG_NAME}_${VERSION}_${DISTRIB_ARCH}.deb $BUILD_DEBS
}
