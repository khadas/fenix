PKG_NAME="gstreamer_rk3399"
PKG_VERSION="9a88826769a9f29fe142faeb999cb26695b51661"
PKG_SHA256="c7327dd90ed8858d560acb24295f30e383e3b6d3bf7009939acfb79c998a512d"
PKG_SOURCE_DIR="gstreamer_rk3399-${PKG_VERSION}*"
PKG_SITE="$GITHUB_URL/numbqq/gstreamer_rk3399"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
[[ $DOWNLOAD_MIRROR == china ]] && \
{
PKG_SITE="$GITEE_URL/numbqq/gstreamer_rk3399"
PKG_URL="$PKG_SITE/repository/archive/$PKG_VERSION.tar.gz"
PKG_SOURCE_DIR="$PKG_NAME"
PKG_SHA256="2c91589c0febfe7363d92c4611be8ce666abcb04d1d356ca81abfe40cfc63ed5"
}
PKG_ARCH="arm64 armhf"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Rockchip Gstreamer hardware encoder/decoder plugins deb packages for RK3399"
PKG_SOURCE_NAME="gstreamer_rk3399-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"

make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/gstreamer
}

