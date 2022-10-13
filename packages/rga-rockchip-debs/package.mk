PKG_NAME="rga-rockchip-debs"
PKG_VERSION="b3565e0aef6695c72c484654814bddadc2dec674"
PKG_SHA256="4f6506ed73c923019f7138326ca7582913ee7d06e7decf063cd70a82c093baa2"
PKG_SOURCE_DIR="rga-rockchip-debs-${PKG_VERSION}*"
PKG_SITE="$GITHUB_URL/numbqq/rga-rockchip-debs"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm64 armhf"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Rockchip RGA deb packages"
PKG_SOURCE_NAME="rga-rockchip-debs-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"

make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/rga-rockchip-debs
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/rga-rockchip-debs/*
	[ -d ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/${KHADAS_BOARD} ] && cp -r ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/${KHADAS_BOARD}/* $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/rga-rockchip-debs || true
}

