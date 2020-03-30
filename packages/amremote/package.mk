PKG_NAME="amremote"
PKG_VERSION="34058bf77fe9c7c42b9af86a46852dd57d865581"
PKG_SHA256="4887bd23bb009b5b95cf01b184af98c518e2501c7a7deb5239924677d8463663"
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
