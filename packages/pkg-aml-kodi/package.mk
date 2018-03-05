PKG_NAME="pkg-aml-kodi"
PKG_VERSION="8b59194"
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
	# set up control file
	mkdir -p DEBIAN
	cat <<-END > DEBIAN/control
	Package: aml-kodi-905
	Version: $VERSION
	Architecture: $UBUNTU_ARCH
	Maintainer: Khadas <hello@khadas.com>
	Installed-Size: 1
	Provides: aml-kodi-905
	Conflicts: aml-kodi-905
	Depends:
	Section: utils
	Priority: optional
	Description: aml-kodi-905
	END

	# pack
	cd ..
	cp -r ${PKG_NAME}-${PKG_VERSION} ${PKG_NAME}_${VERSION}_${UBUNTU_ARCH}
	rm -rf ${PKG_NAME}_${VERSION}_${UBUNTU_ARCH}/.fenix-unpack
	dpkg -b ${PKG_NAME}_${VERSION}_${UBUNTU_ARCH}
	rm -rf ${PKG_NAME}_${VERSION}_${UBUNTU_ARCH}
}

makeinstall_target() {
	mkdir -p $BUILD_IMAGES/$PKG_NAME
	rm -rf $BUILD_IMAGES/$PKG_NAME/*.deb
	mv ${PKG_NAME}_${VERSION}_${UBUNTU_ARCH}.deb $BUILD_IMAGES/$PKG_NAME
}
