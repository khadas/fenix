PKG_NAME="dracut_install"
PKG_VERSION="b89e0a07f7b84edd53e6524e7ef9e470eefcbf9c"
PKG_SHA256="8cadb673e99b8b17a53421e8d0b461c727c409152bfc2d5eb740741c0bf798e0"
PKG_SOURCE_DIR="dracut_install-${PKG_VERSION}*"
PKG_SITE="$GITHUB_URL/numbqq/dracut_install"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="dracut_install"
PKG_SOURCE_NAME="dracut_install-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"


make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/dracut_install
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/dracut_install/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/dracut_install 2> /dev/null || \
	cp -rf ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/${KHADAS_BOARD}/${LINUX}/* $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/dracut_install
}
