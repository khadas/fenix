PKG_NAME="xf86-video-armsoc_s905x"
PKG_VERSION="d5442f1"
PKG_SHA256="a382c2f3055e9be756d3f6218f2680268575828988a996e0d8485dc86c17aa6d"
PKG_SOURCE_DIR="xf86-video-armsoc_s905x-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/xf86-video-armsoc_s905x"
PKG_URL="https://github.com/numbqq/xf86-video-armsoc_s905x/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Open-source X.org graphics driver for ARM graphics"
PKG_SOURCE_NAME="xf86-video-armsoc_s905x-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="YES"


make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/xf86-video-armsoc_s905x
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/xf86-video-armsoc_s905x/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/xf86-video-armsoc_s905x
}
