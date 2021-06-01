PKG_NAME="edid-decode-deb"
PKG_VERSION="ad6429d89755d5fa0fe94f0b0205eaf153e26947"
PKG_SHA256="e5f28c16a6a80c8e7507c07e719b17a8336db504349cf7cd716b24ccfb4426f0"
PKG_SOURCE_DIR="edid-decode-deb-${PKG_VERSION}*"
PKG_SITE="$GITHUB_URL/numbqq/edid-decode-deb"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
[[ $DOWNLOAD_MIRROR == china ]] && \
{
PKG_SITE="$GITEE_URL/numbqq/edid-decode-deb"
PKG_URL="$PKG_SITE/repository/archive/$PKG_VERSION.tar.gz"
PKG_SOURCE_DIR="$PKG_NAME"
PKG_SHA256="512485ac62795d489388b2426e1ae225e72f6ece9070c8eddbd9adcf28c64e83"
}
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SHORTDESC="EDID decoder"
PKG_SOURCE_NAME="edid-decode-deb-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="YES"


make_target() {
	:
}

makeinstall_target() {
	mkdir -p $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/edid-decode-deb
	# Remove old debs
	rm -rf $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/edid-decode-deb/*
	cp ${DISTRIB_RELEASE}/${DISTRIB_ARCH}/*.deb $BUILD_DEBS/$VERSION/$KHADAS_BOARD/${DISTRIBUTION}-${DISTRIB_RELEASE}/edid-decode-deb
}
