PKG_NAME="rga-rockchip"
PKG_VERSION="01afc6915eaea5134bbf969f3282a9f7a8be367c"
PKG_SHA256="eeb9c3d1a147798014182080ff42e6d79849d370d110a421aa9abc5ad16c9d26"
PKG_SOURCE_DIR="rga-rockchip-${PKG_VERSION}*"
PKG_SITE="$GITHUB_URL/yan-wyb/rga-rockchip"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm64 armhf"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Rockchip RGA Process Platform deb packages"
PKG_SOURCE_NAME="mpp-rockchip-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"

make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/rga-rockchip
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/rga-rockchip/*
	[ -d ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/${KHADAS_BOARD} ] && cp -r ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/${KHADAS_BOARD}/* $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}//rga-rockchip || true
}

