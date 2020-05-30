PKG_NAME="mesa_debs"
PKG_VERSION="6da61b64d4fefb6acc7bd67a05c1eb555501d4a5"
PKG_SHA256="b78b4fc8a26ca08a20cd847db7ed5cf865b4251ff3b89fdbf8b7b07279716aaf"
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

