PKG_NAME="amremote_s905x"
PKG_VERSION="ac16907"
PKG_SHA256="c5dad651364d48d8bab72561bdaed9dde380e252af63e57ee4000f2f4b14a0d4"
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
	cp xenial/arm64/*.deb $BUILD_DEBS/amremote_s905x
}
