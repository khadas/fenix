PKG_NAME="libcec_rk3399"
PKG_VERSION="c6a7542a045fb7c3f19f9c3968a1cb810bca9437"
PKG_SHA256="30f3fc822fdf031563e5c05e228cf09a8bc8f9cb891858673b8a850d3e2ac652"
PKG_SOURCE_DIR="libcec_rk3399-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/libcec_rk3399"
PKG_URL="https://github.com/numbqq/libcec_rk3399/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm64 armhf"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Patched LibCEC"
PKG_SOURCE_NAME="libcec_rk3399-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"

make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/libcec
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/libcec/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/libcec
}

