PKG_NAME="mesa_debs"
PKG_VERSION="fb24caac356087935bf95b9a61d62e17e7229de7"
PKG_SHA256="e7dc33cd1414de022027aff15447002b5092930ad6e56db6e26130d12527d739"
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

