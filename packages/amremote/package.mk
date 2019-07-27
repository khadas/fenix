PKG_NAME="amremote"
PKG_VERSION="550e881b59882ff1e71c4c3cf25974de82e506eb"
PKG_SHA256="4f6e95cb99f142157d0aa1318e47c92ef01db888cfa12cd8692e8567f5c72503"
PKG_SOURCE_DIR="amremote-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/amremote"
PKG_URL="https://github.com/numbqq/amremote/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Amlogic Amremote package"
PKG_SOURCE_NAME="amremote-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="YES"


make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/amremote
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/amremote/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/amremote
}
