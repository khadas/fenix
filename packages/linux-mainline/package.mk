PKG_NAME="linux-mainline"
PKG_VERSION="5.10-rc6"
PKG_VERSION_SHORT="v5.x"
PKG_SHA256="d139d4cc8eb8b27364adc774c0df0feac39389beb4357a36d628a48c92fed393"
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
