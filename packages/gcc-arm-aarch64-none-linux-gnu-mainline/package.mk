PKG_NAME="gcc-arm-aarch64-none-linux-gnu-mainline"
PKG_VERSION="11.2-2022.02"
PKG_VERSION_SHORT="11.2-2022.02"
PKG_SHA256="52dbac3eb71dbe0916f60a8c5ab9b7dc9b66b3ce513047baa09fae56234e53f3"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE=""
PKG_URL="https://developer.arm.com/-/media/Files/downloads/gnu/${PKG_VERSION_SHORT}/binrel/gcc-arm-${PKG_VERSION}-x86_64-aarch64-none-linux-gnu.tar.xz"
PKG_SOURCE_DIR="gcc-arm-${PKG_VERSION}-x86_64-aarch64-none-linux-gnu"
PKG_SOURCE_NAME="$(basename $PKG_URL)"
PKG_NEED_BUILD="NO"
PKG_SHORTDESC="GCC for building linux"

makeinstall_host() {
	[ -d "$TOOLCHAINS" ] || mkdir -p "$TOOLCHAINS"
	[ -d "$TOOLCHAINS/$PKG_NAME" ] && rm -rdf "$TOOLCHAINS/$PKG_NAME"
	ln -sf "../$PKG_NAME-$PKG_VERSION" "$TOOLCHAINS/$PKG_NAME"
}
