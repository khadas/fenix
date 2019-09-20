PKG_NAME="npu_aml"
PKG_VERSION="dd55d6dddc3d86cfd32ccc229151060cf86a0b90"
PKG_SHA256="13eec10e8d97afc326124a5203fea2b47f95d5253f0e5138a7f9708c2e6fc250"
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
