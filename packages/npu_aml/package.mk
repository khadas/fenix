PKG_NAME="npu_aml"
PKG_VERSION="944fca462866ee3c9c9856534a42e48349e0a2b1"
PKG_SHA256="e81fa19a48cada3499967c82bdf85a2634e6288bc45d9838719e9ab2e8620b10"
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
