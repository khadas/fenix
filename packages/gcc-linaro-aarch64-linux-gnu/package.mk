PKG_NAME="gcc-linaro-aarch64-linux-gnu"
PKG_VERSION="7.3.1-2018.05"
PKG_VERSION_SHORT="7.3-2018.05"
PKG_SHA256="73eed74e593e2267504efbcf3678918bb22409ab7afa3dc7c135d2c6790c2345"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE=""
PKG_URL="https://build.khadas.com/khadas/fenix/toolchains/gcc-linaro-${PKG_VERSION}-x86_64_aarch64-linux-gnu.tar.xz"
PKG_SOURCE_DIR="gcc-linaro-${PKG_VERSION}-x86_64_aarch64-linux-gnu"
PKG_SOURCE_NAME="$(basename $PKG_URL)"
PKG_NEED_BUILD="NO"
PKG_SHORTDESC="GCC for building linux"

makeinstall_host() {
	[ -d "$TOOLCHAINS" ] || mkdir -p "$TOOLCHAINS"
	[ -d "$TOOLCHAINS/$PKG_NAME" ] && rm -rdf "$TOOLCHAINS/$PKG_NAME"
	ln -sf "../$PKG_NAME-$PKG_VERSION" "$TOOLCHAINS/$PKG_NAME"
}
