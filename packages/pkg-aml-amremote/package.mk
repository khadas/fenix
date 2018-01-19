PKG_NAME="pkg-aml-amremote"
PKG_VERSION="7d064e8"
PKG_SOURCE_DIR="pkg-aml-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/pkg-aml"
PKG_URL="https://github.com/numbqq/pkg-aml/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Amlogic Amremote package"
PKG_SOURCE_NAME="pkg-aml-amremote-${PKG_VERSION}.tar.gz"
PKG_SHA256=""
PKG_NEED_BUILD="YES"


make_target() {
	rm -rf .fenix-unpack
	# set up control file
	mkdir -p DEBIAN
	cat <<-END > DEBIAN/control
	Package: aml-amremote-905
	Version: 0.1
	Architecture: $UBUNTU_ARCH
	Maintainer: Khadas <hello@khadas.com>
	Installed-Size: 1
	Provides: aml-amremote-905
	Conflicts: aml-amremote-905
	Section: kernel
	Priority: optional
	Description: IR amremote S905
	END

	# pack
	cd ..
	mv ${PKG_NAME}-${PKG_VERSION} ${PKG_NAME}-${PKG_VERSION}_${UBUNTU_ARCH}
	dpkg -b ${PKG_NAME}-${PKG_VERSION}_${UBUNTU_ARCH}
	mv ${PKG_NAME}-${PKG_VERSION}_${UBUNTU_ARCH} ${PKG_NAME}-${PKG_VERSION}
}

makeinstall_target() {
	mkdir -p $BUILD_IMAGES/$PKG_NAME
	rm -rf $BUILD_IMAGES/$PKG_NAME/*.deb
	mv ${PKG_NAME}-${PKG_VERSION}_${UBUNTU_ARCH}.deb $BUILD_IMAGES/$PKG_NAME
}
