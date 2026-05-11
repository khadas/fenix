PKG_NAME="ffmpeg-debs"
PKG_VERSION="b271b57c304d03b7de08af0276bf1e0045dd47df"
PKG_SHA256="6a0d7e640e1fd6011b10ba152ce99a2bf9b601fd3362a4c7d107325f4ff376bb"
PKG_SOURCE_DIR="ffmpeg-debs-${PKG_VERSION}*"
PKG_SITE="$GITHUB_URL/numbqq/ffmpeg-debs"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm64 armhf"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Rockchip ffmpeg deb packages"
PKG_SOURCE_NAME="ffmpeg-debs-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"

make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/ffmpeg-debs
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/ffmpeg-debs/*
	[ -d ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/${KHADAS_BOARD} ] && cp -r ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/${KHADAS_BOARD}/* $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/ffmpeg-debs || true
}

