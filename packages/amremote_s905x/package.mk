PKG_NAME="amremote_s905x"
PKG_VERSION="5fe49d2d520e9f89429cff0fbf955c33cc93faf8"
PKG_SHA256="637ef9fbc78c06753c8dcb02ffdab6d14cb68909c250fe1500e826835ee38f7e"
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
