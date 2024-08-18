PKG_NAME="fenix-config"
PKG_VERSION="faa2e8358ad4f59b245a451e84d150b4b92de648"
PKG_SHA256="e387b7e420d282bb60216895c4619946c38e0a96d75c7ede5abafc748ffe1aca"
PKG_SOURCE_DIR="${PKG_NAME}-${PKG_VERSION}*"
PKG_SITE="$GITHUB_URL/viraniac/${PKG_NAME}"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
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
	Depends: bash, bc, build-essential, curl, dialog, debconf, debconf-utils, dirmngr, expect, html2text, iperf3, jq, psmisc, pv, software-properties-common, unzip, zip
	Suggests: libpam-google-authenticator, qrencode, network-manager
	Section: utils
	Priority: optional
	Description: Fenix configuration utility
	EOF

	mkdir -p "${pkgdir}"/usr/{bin,lib/fenix-config,sbin}
	install -m 755 fenix-config "${pkgdir}"/usr/sbin/fenix-config
	install -m 644 fenix-config-jobs "${pkgdir}"/usr/lib/fenix-config/jobs.sh
	install -m 644 fenix-config-submenu "${pkgdir}"/usr/lib/fenix-config/submenu.sh
	install -m 644 fenix-config-functions "${pkgdir}"/usr/lib/fenix-config/functions.sh
	install -m 644 fenix-config-functions-network "${pkgdir}"/usr/lib/fenix-config/functions-network.sh
	install -m 755 softy "${pkgdir}"/usr/sbin/softy

	ln -sf /usr/sbin/fenix-config "${pkgdir}"/usr/bin/fenix-config
	ln -sf /usr/sbin/softy "${pkgdir}"/usr/bin/softy

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
