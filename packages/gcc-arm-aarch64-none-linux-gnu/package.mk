PKG_NAME="gcc-arm-aarch64-none-linux-gnu"
PKG_VERSION="10.3-2021.07"
PKG_VERSION_SHORT="10.3-2021.07"
PKG_SHA256="1e33d53dea59c8de823bbdfe0798280bdcd138636c7060da9d77a97ded095a84"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE=""
PKG_URL="https://developer.arm.com/-/media/Files/downloads/gnu-a/${PKG_VERSION_SHORT}/binrel/gcc-arm-${PKG_VERSION}-x86_64-aarch64-none-linux-gnu.tar.xz"
PKG_SOURCE_DIR="gcc-arm-${PKG_VERSION}-x86_64-aarch64-none-linux-gnu"
PKG_SOURCE_NAME="$(basename $PKG_URL)"
PKG_NEED_BUILD="NO"
PKG_SHORTDESC="GCC for building linux"

makeinstall_host() {
	[ -d "$TOOLCHAINS" ] || mkdir -p "$TOOLCHAINS"
	[ -d "$TOOLCHAINS/$PKG_NAME" ] && rm -rdf "$TOOLCHAINS/$PKG_NAME"
	ln -sf "../$PKG_NAME-$PKG_VERSION" "$TOOLCHAINS/$PKG_NAME"
}
