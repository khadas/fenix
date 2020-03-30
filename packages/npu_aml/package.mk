PKG_NAME="npu_aml"
PKG_VERSION="375c75cce008afde5dd3cfbf124f8d6e70fece40"
PKG_SHA256="6929c201513a5a3730bfc74a6970d3a6ef080ebccdd69a80757200b9efad7f33"
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
