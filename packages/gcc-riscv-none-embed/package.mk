PKG_NAME="gcc-riscv-none-embed"
PKG_VERSION="8.3.0-1.2"
PKG_VERSION_SHORT=""
PKG_SHA256="079a88d7f7c18cfd735a9ed1f0eefa28ab28d3007b5f7591920ab25225c89248"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE=""
PKG_URL="https://github.com/xpack-dev-tools/riscv-none-embed-gcc-xpack/releases/download/v${PKG_VERSION}/xpack-riscv-none-embed-gcc-${PKG_VERSION}-linux-x64.tar.gz"
PKG_SOURCE_DIR="xpack-riscv-none-embed-gcc-${PKG_VERSION}"
PKG_SOURCE_NAME="$(basename $PKG_URL)"
PKG_NEED_BUILD="NO"
PKG_SHORTDESC="RISC-V GCC"

makeinstall_host() {
	[ -d "$TOOLCHAINS" ] || mkdir -p "$TOOLCHAINS"
	[ -d "$TOOLCHAINS/$PKG_NAME" ] && rm -rdf "$TOOLCHAINS/$PKG_NAME"
	ln -sf "../$PKG_NAME-$PKG_VERSION" "$TOOLCHAINS/$PKG_NAME"
}
