PKG_NAME="gcc-arm-aarch64-none-linux-gnu"
PKG_VERSION="12.2.rel1"
PKG_VERSION_SHORT="12.2.rel1"
PKG_SHA256="6e8112dce0d4334d93bd3193815f16abe6a2dd5e7872697987a0b12308f876a4"
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
