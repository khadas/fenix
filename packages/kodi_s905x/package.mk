PKG_NAME="kodi_s905x"
PKG_VERSION="bd99c8a"
PKG_SHA256="a11c983e3f1c4923c445264bbb579f82f112c4247b41c1daf1cc44de52665b97"
PKG_SOURCE_DIR="kodi_s905x-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/kodi_s905x"
PKG_URL="https://github.com/numbqq/kodi_s905x/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Amlogic S905X Kodi package"
PKG_SOURCE_NAME="kodi_s905x-${PKG_VERSION}.tar.gz"
PKG_SHA256=""
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
