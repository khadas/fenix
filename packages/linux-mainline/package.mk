PKG_NAME="linux-mainline"
PKG_VERSION="4.17.13"
PKG_VERSION_SHORT="v4.x"
PKG_SHA256="820b3ebb09a165aeceb39822782aca8f3ef044bb9c01015d9c126e2e87563f74"
PKG_SOURCE_DIR="linux-${PKG_VERSION}"
PKG_SITE="https://cdn.kernel.org/"
PKG_URL="https://cdn.kernel.org/pub/linux/kernel/${PKG_VERSION_SHORT}/linux-${PKG_VERSION}.tar.xz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Mainline linux"
PKG_SOURCE_NAME="linux-${PKG_VERSION}.tar.xz"
PKG_NEED_BUILD="YES"


make_target() {

	export PATH=$TOOLCHAINS/gcc-linaro-aarch64-linux-gnu/bin/:$PATH

#	make ARCH=arm64 distclean
	make ARCH=arm64 defconfig

	make -j8 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image modules dtbs
}

makeinstall_target() {
	mkdir -p $BUILD_IMAGES/$PKG_NAME
	cp arch/arm64/boot/dts/amlogic/meson-gxl-s905x-khadas-vim.dtb $BUILD_IMAGES/$PKG_NAME
	cp arch/arm64/boot/Image $BUILD_IMAGES/$PKG_NAME
}
