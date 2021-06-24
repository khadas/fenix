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
	export ARCH=arm64
	export CROSS_COMPILE="${CCACHE} ${KERNEL_COMPILER}"
	export INSTALL_MOD_STRIP=1

	[ "$KERNEL_INSTALL_PATH" ] || \
	    KERNEL_INSTALL_PATH="$BUILD/linux-mainline-install"

	[ "$INSTALL_PATH" ] || \
	    INSTALL_PATH="$KERNEL_INSTALL_PATH/boot"

	[ "$INSTALL_MOD_PATH" ] || \
	    INSTALL_MOD_PATH="$KERNEL_INSTALL_PATH"

	export INSTALL_MOD_PATH
	export INSTALL_PATH

	echo "KERNEL_INSTALL_PATH: $KERNEL_INSTALL_PATH"

# KERNEL_MAKE_ARGS=menuconfig make kernel

	case "$KERNEL_MAKE_ARGS" in
	    "")
	    KERNEL_MAKE_ARGS="prepare Image modules dtbs"
	    ;;
	esac

	c=$PKGS_DIR/$PKG_NAME/configs/${KHADAS_BOARD}.config

	case $KERNEL_CONFIG in
	    "")
	    ;;
	    -)
	    c=
	    ;;
	    *.config*)
	    for c in "$KERNEL_CONFIG" "$PKGS_DIR/$PKG_NAME/configs/$KERNEL_CONFIG" ""; do
	    [ -e "$c" ] && break
	    done
	    ;;
	    *)
	    error_msg "KERNEL_CONFIG: $KERNEL_CONFIG is wrong"
	    return 1
	    ;;
	esac

	[ "$c" ] && {
	    diff -q "$c" .config || {
		echo "KERNEL config updated from $c"
		cp "$c" .config
	    }
	}

	[ ! "$BUILD_LINUX_NOOP" ] || return 0

	for k in $KERNEL_MAKE_ARGS; do

	    case $k in
		install)
		mkdir -p $INSTALL_PATH
		;;
	    esac

	    echo "KERNEL: make $k"
	    make -j${NR_JOBS} $k

	done

}

makeinstall_target() {
	:
}
