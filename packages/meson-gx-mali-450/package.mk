PKG_NAME="meson-gx-mali-450"
PKG_VERSION="cb85e7d97d4c57c640ddb1a92cdb41db37ca98a4"
PKG_SHA256="85a2c4fa9903bb889553acba1ebf6ad378f33c1510c4adb84773cf881bd486f8"
PKG_SOURCE_DIR="meson_gx_mali_450-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/meson_gx_mali_450"
PKG_URL="https://github.com/numbqq/meson_gx_mali_450/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Amlogic GX Mali support for Mali-450 based SoCs, for Mainline Linux only"
PKG_SOURCE_NAME="meson-gx-mali-450-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="YES"


make_target() {

	(KDIR=$BUILD/linux-mainline-*/ ./build.sh)
}

makeinstall_target() {
	mkdir -p $BUILD_IMAGES/$PKG_NAME
	rm -rf $BUILD_IMAGES/$PKG_NAME/*
	cp mali.ko $BUILD_IMAGES/$PKG_NAME/mali-${MAINLINE_LINUX_VER}.ko
}
