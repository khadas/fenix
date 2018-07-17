PKG_NAME="kodi_s905x"
PKG_VERSION="071c26a"
PKG_SHA256="8c0376113023829153ed183775d656aa840cab171382275d66e0fdc9e944f907"
PKG_SOURCE_DIR="kodi_s905x-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/kodi_s905x"
PKG_URL="https://github.com/numbqq/kodi_s905x/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Amlogic S905X Kodi package"
PKG_SOURCE_NAME="kodi_s905x-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="YES"


make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/kodi_s905x
	# Remove old debs
	rm -rf $BUILD_DEBS/kodi_s905x/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/kodi_s905x
}
