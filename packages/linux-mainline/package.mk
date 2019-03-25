PKG_NAME="linux-mainline"
PKG_VERSION="5.0.4"
PKG_VERSION_SHORT="v5.x"
PKG_SHA256="8f853aa05c496e27452da5e0ca74c56fab447cb2c24f047c55fd1d13d8bdea68"
PKG_SOURCE_DIR="linux-${PKG_VERSION}"
PKG_SITE="https://cdn.kernel.org/"
PKG_URL="https://cdn.kernel.org/pub/linux/kernel/${PKG_VERSION_SHORT}/linux-${PKG_VERSION}.tar.xz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Mainline linux"
PKG_SOURCE_NAME="linux-${PKG_VERSION}.tar.xz"
PKG_NEED_BUILD="YES"


make_target() {

	export PATH=$KERNEL_COMPILER_PATH:$PATH

#	make ARCH=arm64 distclean
	make ARCH=arm64 CROSS_COMPILE=${KERNEL_COMPILER} ${LINUX_DEFCONFIG}

	# Apply configuration
	cp $PKGS_DIR/$PKG_NAME/configs/${KHADAS_BOARD}.config .config

	make -j${NR_JOBS} ARCH=arm64 CROSS_COMPILE=${KERNEL_COMPILER} Image modules dtbs
}

makeinstall_target() {
	:
}
