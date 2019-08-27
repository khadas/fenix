PKG_NAME="gcc-linaro-aarch64-linux-gnu-6.3"
PKG_VERSION="6.3.1-2017.02"
PKG_VERSION_SHORT="6.3-2017.02"
PKG_SHA256="10670e1c5d2ab77b937a26cc7f2a22e8eb6cb223e2df7c763f02ce63339e66bc"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE=""
PKG_URL="https://releases.linaro.org/components/toolchain/binaries/${PKG_VERSION_SHORT}/aarch64-linux-gnu/gcc-linaro-${PKG_VERSION}-x86_64_aarch64-linux-gnu.tar.xz"
PKG_SOURCE_DIR="gcc-linaro-${PKG_VERSION}-x86_64_aarch64-linux-gnu"
PKG_SOURCE_NAME="$(basename $PKG_URL)"
PKG_NEED_BUILD="NO"
PKG_SHORTDESC="GCC for building linux"

makeinstall_host() {
#	mkdir -p $TOOLCHAINS/gcc-linaro-aarch64-linux-gnu-6.3/
#	rm -rf $TOOLCHAINS/gcc-linaro-aarch64-linux-gnu-6.3/*
#	cp -a $BUILD/$PKG_NAME-$PKG_VERSION/* $TOOLCHAINS/gcc-linaro-aarch64-linux-gnu-6.3
	[ -d "$TOOLCHAINS" ] || mkdir -p "$TOOLCHAINS"
	[ -d "$TOOLCHAINS/$PKG_NAME" ] && rm -rd "$TOOLCHAINS/$PKG_NAME"
	ln -sf "../$PKG_NAME-$PKG_VERSION" "$TOOLCHAINS/$PKG_NAME"
}
