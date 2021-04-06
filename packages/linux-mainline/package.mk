PKG_NAME="linux-mainline"
PKG_VERSION="5.12-rc5"
PKG_VERSION_SHORT="v5.x"
PKG_SHA256="d50e17bbef66e6a52342f0e1fa16fae1400030bd7159787dca51f834f1780618"
PKG_SOURCE_DIR="linux-${PKG_VERSION}"
PKG_SITE="https://cdn.kernel.org/"
#PKG_URL="https://cdn.kernel.org/pub/linux/kernel/${PKG_VERSION_SHORT}/linux-${PKG_VERSION}.tar.xz"
PKG_URL="https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/snapshot/linux-${PKG_VERSION}.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Mainline linux"
PKG_SOURCE_NAME="linux-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="YES"


make_target() {

	export PATH=$KERNEL_COMPILER_PATH:$PATH

#	make ARCH=arm64 distclean
	make ARCH=arm64 CROSS_COMPILE="${CCACHE} ${KERNEL_COMPILER}" ${LINUX_DEFCONFIG}

	# Apply configuration
	cp $PKGS_DIR/$PKG_NAME/configs/${KHADAS_BOARD}.config .config

	make -j${NR_JOBS} ARCH=arm64 CROSS_COMPILE="${CCACHE} ${KERNEL_COMPILER}" Image modules dtbs
}

makeinstall_target() {
	:
}
