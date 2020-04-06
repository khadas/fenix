PKG_NAME="linux-mainline"
PKG_VERSION="5.5-rc2"
PKG_VERSION_SHORT="v5.x"
PKG_SHA256="aca303b87c818cb41c2ddfd4c06d3fcaa85e935fbd61ea203232ccd2a81844bb"
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

#	make distclean
	make ${LINUX_DEFCONFIG}

	# Apply configuration
	cp $PKGS_DIR/$PKG_NAME/configs/${KHADAS_BOARD}.config .config

	make -j${JOBS} Image modules dtbs 
}

makeinstall_target() {
	:
}
