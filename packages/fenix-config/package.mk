PKG_NAME="fenix-config"
PKG_VERSION="99fa015ab5bc7d0a49848b66f1c58d19efbd1967"
PKG_SHA256="cea5dbafcbf3c4ae593e4bb20d311679aaa66c54bcec353c2dad3d087fbdbc5d"
PKG_SOURCE_DIR="${PKG_NAME}-${PKG_VERSION}*"
PKG_SITE="$GITHUB_URL/numbqq/${PKG_NAME}"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL 2.0"
PKG_SHORTDESC="Linux configuration utility"
PKG_SOURCE_NAME="${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="YES"


make_target() {
	local pkgdir="$BUILD_IMAGES/.tmp/${PKG_NAME}_${VERSION}_${DISTRIB_ARCH}"
	rm -rf $pkgdir
	mkdir -p $pkgdir/DEBIAN

	# set up control file
	cat <<-EOF > $pkgdir/DEBIAN/control
	Package: ${PKG_NAME}
	Version: ${VERSION}
	Architecture: all
	Maintainer: Khadas <hello@khadas.com>
	Depends: bash, jq, whiptail
	Suggests: libpam-google-authenticator, qrencode, network-manager, netplan.io
	Section: utils
	Priority: optional
	Description: Fenix configuration utility
	EOF

	mkdir -p "${pkgdir}"/usr/{bin,lib/fenix-config}
	find bin lib -type f -exec install -m 644 {} "${pkgdir}"/usr/{} \;
	chmod a+x "${pkgdir}"/usr/bin/fenix-config

	info_msg "Building package: $pkgname"
	fakeroot dpkg-deb -b -Zxz $pkgdir ${pkgdir}.deb

	# Cleanup
	rm -rf $pkgdir
}

makeinstall_target() {
	local pkgdir="$BUILD_IMAGES/.tmp/${PKG_NAME}_${VERSION}_${DISTRIB_ARCH}"
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/${PKG_NAME}/
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/${PKG_NAME}/*
	cp ${pkgdir}.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/${PKG_NAME}/

	# Cleanup
	rm -f ${pkgdir}.deb
}
