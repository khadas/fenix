PKG_NAME="gcc-linaro-aarch64-elf"
PKG_VERSION="7.3.1-2018.05"
PKG_VERSION_SHORT="7.3-2018.05"
PKG_SHA256="e73d1886fb67d5a03c0ca5be14aeab6b7b7be3fce46ad1473ba864d5eb1d2545"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE=""
PKG_URL="https://releases.linaro.org/components/toolchain/binaries/${PKG_VERSION_SHORT}/aarch64-elf/gcc-linaro-${PKG_VERSION}-x86_64_aarch64-elf.tar.xz"
PKG_SOURCE_DIR="gcc-linaro-${PKG_VERSION}-x86_64_aarch64-elf"
PKG_SOURCE_NAME="$(basename $PKG_URL)"
PKG_NEED_BUILD="NO"
PKG_SHORTDESC="GCC for building mainline U-Boot"

makeinstall_host() {
	[ -d "$TOOLCHAINS" ] || mkdir -p "$TOOLCHAINS"
	[ -d "$TOOLCHAINS/$PKG_NAME" ] && rm -rdf "$TOOLCHAINS/$PKG_NAME"
	ln -sf "../$PKG_NAME-$PKG_VERSION" "$TOOLCHAINS/$PKG_NAME"
}
