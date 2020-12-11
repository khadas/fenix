PKG_NAME="encoder_libs_deb_aml"
PKG_VERSION="9b347c8801aa79eb887f3c9cff5f65653d40cbfe"
PKG_SHA256="c522dd69580a8344f8f27fb28c714e8aa33088d7bc0addfff1a5697fee3cd2c7"
PKG_SOURCE_DIR="${PKG_NAME}-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/${PKG_NAME}"
PKG_URL="https://github.com/numbqq/${PKG_NAME}/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Amlogic H264/H264 encoder libraries."
PKG_SOURCE_NAME="${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"

make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/encoder
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/encoder/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/encoder
}

