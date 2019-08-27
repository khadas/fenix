PKG_NAME="gcc-arm-none-eabi"
PKG_VERSION="6-2017-q2-update"
PKG_VERSION_SHORT="6-2017q2"
PKG_SHA256=""
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE=""
PKG_URL="https://developer.arm.com/-/media/Files/downloads/gnu-rm/${PKG_VERSION_SHORT}/gcc-arm-none-eabi-${PKG_VERSION}-linux.tar.bz2"
PKG_SOURCE_DIR="gcc-arm-none-eabi-${PKG_VERSION}-linux"
PKG_SOURCE_NAME="$(basename $PKG_URL)"
PKG_NEED_BUILD="NO"
PKG_SHORTDESC="GCC for building Amlogic U-Boot firmware"

makeinstall_host() {
#	mkdir -p $TOOLCHAINS/gcc-arm-none-eabi/
#	rm -rf $TOOLCHAINS/gcc-arm-none-eabi/*
#	cp -a $BUILD/$PKG_NAME-$PKG_VERSION/* $TOOLCHAINS/gcc-arm-none-eabi
	[ -d "$TOOLCHAINS" ] || mkdir -p "$TOOLCHAINS"
	[ -d "$TOOLCHAINS/$PKG_NAME" ] && rm -rdf "$TOOLCHAINS/$PKG_NAME"
	ln -sf ../$PKG_NAME-$PKG_VERSION $TOOLCHAINS/$PKG_NAME
}
