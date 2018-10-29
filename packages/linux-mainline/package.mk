PKG_NAME="linux-mainline"
PKG_VERSION="4.18.16"
PKG_VERSION_SHORT="v4.x"
PKG_SHA256="beba14e2f07259a545baa1dce5afdaf9f470cdadc8b378ac269e7c8a289c52e6"
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
