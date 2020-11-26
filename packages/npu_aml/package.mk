PKG_NAME="npu_aml"
PKG_VERSION="22535e2785fc04fa029ff6e0fa7e96f61d324191"
PKG_SHA256="d362cb6a88b8be0a20dacedae42a759dc842bbebbb1769277e892a4c7514af72"
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
