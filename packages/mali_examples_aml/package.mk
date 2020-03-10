PKG_NAME="mali_examples_aml"
PKG_VERSION="990b2ea7c978b570a4f6a0aeacc9edf2de7e4dcb"
PKG_SHA256="4fb5bafda013d798b15f99ae1fba25d7ffca4fa8fdf369ea3252a26682bfe35a"
PKG_SOURCE_DIR="mali_examples_aml-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/mali_examples_aml"
PKG_URL="https://github.com/numbqq/mali_examples_aml/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Mali OpenGL ES 2.0 examples."
PKG_SOURCE_NAME="mali_examples_aml-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"


make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mali_examples_aml
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mali_examples_aml/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mali_examples_aml
}
