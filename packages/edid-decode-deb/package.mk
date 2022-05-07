PKG_NAME="edid-decode-deb"
PKG_VERSION="15015ca1e7b6f0e1e5717b93054421a419cc5db9"
PKG_SHA256="6d0f66877a54226befece3a3af65d6f48c1083d38ede7ce51e60ea6b0a8d6db5"
PKG_SOURCE_DIR="edid-decode-deb-${PKG_VERSION}*"
PKG_SITE="$GITHUB_URL/numbqq/edid-decode-deb"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="EDID decoder"
PKG_SOURCE_NAME="edid-decode-deb-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="YES"


make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/edid-decode-deb
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/edid-decode-deb/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/edid-decode-deb
}
