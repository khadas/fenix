PKG_NAME="mesa_debs"
PKG_VERSION="624ab18b55cdd00c7a0223db2b52c9b6021aec89"
PKG_SHA256="6be90502fb5b0d3b24cad910d48f70e8f8f6f7010f55806d4e9d611ba35120f1"
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

