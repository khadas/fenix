PKG_NAME="amremote_s905x"
PKG_VERSION="fac5142"
PKG_SHA256="a27d7eb709e2c22da3c5c08db48a90c95717acbe7aab0e18cef957b6bb8b2686"
PKG_SOURCE_DIR="amremote_s905x-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/amremote_s905x"
PKG_URL="https://github.com/numbqq/amremote_s905x/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Amlogic Amremote package"
PKG_SOURCE_NAME="amremote_s905x-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="YES"


make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/amremote_s905x
	# Remove old debs
	rm -rf $BUILD_DEBS/amremote_s905x/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/amremote_s905x
}
