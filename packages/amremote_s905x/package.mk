PKG_NAME="amremote_s905x"
PKG_VERSION="278a5e3"
PKG_SHA256="bdf09fd9c949dc3230a8b0e2ed92a9172a0e5839463d3f673b2fb6c9e9827e57"
PKG_SOURCE_DIR="amremote_s905x-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/amremote_s905x"
PKG_URL="https://github.com/numbqq/amremote_s905x/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Amlogic Amremote package"
PKG_SOURCE_NAME="amremote_s905x-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="YES"


make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/amremote_s905x
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/amremote_s905x/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/amremote_s905x
}
