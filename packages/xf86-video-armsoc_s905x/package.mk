PKG_NAME="xf86-video-armsoc_s905x"
PKG_VERSION="d5442f1781014a6650919eef97536f1de288bd5d"
PKG_SHA256="5410398f04fa5c93d6839ccda22f327affad7070d8e97baeec3dc72ae0872a47"
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
	if [ -d ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/ ]; then
		cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/xf86-video-armsoc_s905x
	fi
}
