PKG_NAME="mesa_debs"
PKG_VERSION="b7723c63f899c16622034816a83aa39351be788b"
PKG_SHA256="8330b197823a217ee4ddb63f5e31d4e4ec92e9466cce5ca5df21e028e9f834fd"
PKG_SOURCE_DIR="mesa_debs-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/${PKG_NAME}"
PKG_URL="https://github.com/numbqq/${PKG_NAME}/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm64 armhf"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Mesa libraies with Lima/Panfrost support."
PKG_SOURCE_NAME="${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"

make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mesa
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mesa/*
	cp -r ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/* $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mesa
}

