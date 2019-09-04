PKG_NAME="npu_aml"
PKG_VERSION="05d0b4f1c39fa5f2f9db59350af71192653a10ba"
PKG_SHA256="0cf030b8f0d5f4a7fd35f1b31c4e45fb9f1ed8f37eac4ef6537a0dea9c60ac05"
PKG_SOURCE_DIR="npu_aml-${PKG_VERSION}*"
PKG_SITE="https://github.com/numbqq/npu_aml"
PKG_URL="https://github.com/numbqq/npu_aml/archive/$PKG_VERSION.tar.gz"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Amlogic NPU libraries"
PKG_SOURCE_NAME="npu_aml-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="YES"


make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/npu_aml
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/npu_aml/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/npu_aml
}
