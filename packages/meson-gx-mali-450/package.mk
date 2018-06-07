PKG_NAME="meson-gx-mali-450"
PKG_VERSION="ce0e04f"
PKG_SHA256="7059f5635b99d93ac836ee21ff4651a3557d073542d9e7f0826dd2db4b543610"
PKG_SOURCE_DIR="meson_gx_mali_450-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/meson_gx_mali_450"
PKG_URL="https://github.com/numbqq/meson_gx_mali_450/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Amlogic GX Mali support for Mali-450 based SoCs, for Mainline Linux only"
PKG_SOURCE_NAME="meson-gx-mali-450-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="YES"


make_target() {

	export PATH=$TOOLCHAINS/gcc-linaro-aarch64-linux-gnu/bin/:$PATH
	(KDIR=$BUILD/linux-mainline-*/ ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- ./build.sh)
}

makeinstall_target() {
	mkdir -p $BUILD_IMAGES/$PKG_NAME
	rm -rf $BUILD_IMAGES/$PKG_NAME/*
	cp mali.ko $BUILD_IMAGES/$PKG_NAME
}
