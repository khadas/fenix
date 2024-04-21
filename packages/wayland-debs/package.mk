PKG_NAME="wayland-debs"
PKG_VERSION="d269e0ed0c700a4d787f2aa4ee01bcff562a6f63"
PKG_SHA256="82bce9f2b34d52e1fbfbc926c3cc3af11ecd9051222ee8233b1dcd25e3b05aed"
PKG_SOURCE_DIR="${PKG_NAME}-${PKG_VERSION}*"
PKG_SITE="$GITHUB_URL/numbqq/${PKG_NAME}"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="aarch64"
PKG_LICENSE="MIT"
PKG_SHORTDESC="Wayland Libraries"
PKG_SOURCE_NAME="${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"


make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/wayland-debs
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/wayland-debs/*
	[ -d ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/${KHADAS_BOARD} ] && cp -r ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/${KHADAS_BOARD}/* $BUILD_DEBS/$VERSION/$KHADAS_BOARD/wayland-debs || true
}
