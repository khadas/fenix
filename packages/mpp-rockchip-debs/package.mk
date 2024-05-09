PKG_NAME="mpp-rockchip-debs"
PKG_VERSION="0d3aa2661362a79ee085d96613802da1c1a2dc3c"
PKG_SHA256="b4f4745cca7743985b106cd49ca2c20822e53b2f3c7045162014cf82951c7ce9"
PKG_SOURCE_DIR="mpp-rockchip-debs-${PKG_VERSION}*"
PKG_SITE="$GITHUB_URL/numbqq/mpp-rockchip-debs"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm64 armhf"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Rockchip Media Process Platform deb packages"
PKG_SOURCE_NAME="mpp-rockchip-debs-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"

make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mpp-rockchip-debs
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mpp-rockchip-debs/*
	[ -d ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/${KHADAS_BOARD} ] && cp -r ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/${KHADAS_BOARD}/* $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/mpp-rockchip-debs || true
}

