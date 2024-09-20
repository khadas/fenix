PKG_NAME="fenix-config"
PKG_VERSION="a510ad225bcc4850d65e0001f482ca9039a8fece"
PKG_SHA256="4291271eaa5eb82cb8bbacd0492e5f94479e2ef457ce69cccc920cc39fa89fe9"
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
	find bin lib -exec install -m 644 {} "${pkgdir}"/usr/{} \;
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
