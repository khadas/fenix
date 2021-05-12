PKG_NAME="linux-mainline"
PKG_VERSION="5.12"
PKG_VERSION_SHORT="v5.x"
PKG_SHA256="1c9334afe7a3b805d8d5127ee31441418c795242a3ac30789fa391a0bdeb125b"
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

	[ ! "$BUILD_LINUX_NOOP" ] || return 0

	make -j${NR_JOBS} ARCH=arm64 CROSS_COMPILE="${CCACHE} ${KERNEL_COMPILER}" Image modules dtbs
}

makeinstall_target() {
	:
}
