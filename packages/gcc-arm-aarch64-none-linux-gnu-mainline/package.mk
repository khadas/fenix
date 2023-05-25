PKG_NAME="gcc-arm-aarch64-none-linux-gnu-mainline"
PKG_VERSION="11.3.rel1"
PKG_VERSION_SHORT="11.3.rel1"
PKG_SHA256="50cdef6c5baddaa00f60502cc8b59cc11065306ae575ad2f51e412a9b2a90364"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE=""
PKG_URL="https://developer.arm.com/-/media/Files/downloads/gnu/${PKG_VERSION_SHORT}/binrel/arm-gnu-toolchain-${PKG_VERSION}-x86_64-aarch64-none-linux-gnu.tar.xz"
PKG_SOURCE_DIR="arm-gnu-toolchain-${PKG_VERSION}-x86_64-aarch64-none-linux-gnu"
PKG_SOURCE_NAME="$(basename $PKG_URL)"
PKG_NEED_BUILD="NO"
PKG_SHORTDESC="GCC for building linux"

makeinstall_host() {
	[ -d "$TOOLCHAINS" ] || mkdir -p "$TOOLCHAINS"
	[ -d "$TOOLCHAINS/$PKG_NAME" ] && rm -rdf "$TOOLCHAINS/$PKG_NAME"
	ln -sf "../$PKG_NAME-$PKG_VERSION" "$TOOLCHAINS/$PKG_NAME"
}
