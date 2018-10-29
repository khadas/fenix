PKG_NAME="linux-mainline"
PKG_VERSION="4.19"
PKG_VERSION_SHORT="v4.x"
PKG_SHA256="0c68f5655528aed4f99dae71a5b259edc93239fa899e2df79c055275c21749a1"
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

	make -j${NR_JOBS} ARCH=arm64 CROSS_COMPILE=${KERNEL_COMPILER} Image modules dtbs
}

makeinstall_target() {
	:
}
