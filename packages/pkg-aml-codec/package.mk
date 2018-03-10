PKG_NAME="pkg-aml-codec"
PKG_VERSION="a361170"
PKG_SOURCE_DIR="pkg-aml-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/pkg-aml"
PKG_URL="https://github.com/numbqq/pkg-aml/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="libamcodec: Interface library for Amlogic media codecs"
PKG_SOURCE_NAME="pkg-aml-codec-${PKG_VERSION}.tar.gz"
PKG_SHA256=""
PKG_NEED_BUILD="YES"


make_target() {
	# set up control file
	mkdir -p DEBIAN
	cat <<-END > DEBIAN/control
	Package: aml-libamcodec-905
	Version: $VERSION
	Architecture: $UBUNTU_ARCH
	Maintainer: Khadas <hello@khadas.com>
	Installed-Size: 1
	Provides: aml-libamcodec-905
	Conflicts: aml-libamcodec-905
	Depends:
	Section: utils
	Priority: optional
	Description: aml-libamcodec-905
	END

	# pack
	cd ..
	cp -r ${PKG_NAME}-${PKG_VERSION} ${PKG_NAME}_${VERSION}_${UBUNTU_ARCH}
	rm -rf ${PKG_NAME}_${VERSION}_${UBUNTU_ARCH}/.fenix-unpack
	dpkg -b ${PKG_NAME}_${VERSION}_${UBUNTU_ARCH}
	rm -rf ${PKG_NAME}_${VERSION}_${UBUNTU_ARCH}
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS
	mv ${PKG_NAME}_${VERSION}_${UBUNTU_ARCH}.deb $BUILD_DEBS
}
