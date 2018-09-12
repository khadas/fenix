PKG_NAME="amremote_s905x"
PKG_VERSION="278a5e3"
PKG_SHA256="34f403e8bb77977d9d721d2322ae6137aaa9444aea79c987037e4b4d842e90ff"
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
