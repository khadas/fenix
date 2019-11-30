PKG_NAME="edid-decode-deb"
PKG_VERSION="970c43074b4caf4d4d4e71825c48d33438387ce8"
PKG_SHA256="fb60baa926c3d9c99131720cc4a4008b02501f76084e49cb0b94daa771aaa6eb"
PKG_SOURCE_DIR="edid-decode-deb-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/edid-decode-deb"
PKG_URL="https://github.com/numbqq/edid-decode-deb/archive/$PKG_VERSION.tar.gz"
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
