PKG_NAME="images_upgrade"
PKG_VERSION="df70a352d25388eff7e25e59d0efda80ad26bf2b"
PKG_SHA256="a955630eafcb73c96c7cd6c8325357bb52120e2a4e3a5d51fc0a8f7007f5acd8"
PKG_SOURCE_DIR="images_upgrade-${PKG_VERSION}*"
PKG_SITE="$GITHUB_URL/khadas/images_upgrade"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
[[ $DOWNLOAD_MIRROR == china ]] && \
{
PKG_SITE="$GITEE_URL/khadas/images_upgrade"
PKG_URL="$PKG_SITE/repository/archive/$PKG_VERSION.tar.gz"
PKG_SOURCE_DIR="$PKG_NAME"
PKG_SHA256="75c62a5b519ae8bb3e0091a05c1cd98c4815dd1b0dddfa8d7f34093ff1f38355"
}
PKG_ARCH="X86"
PKG_LICENSE="GPL"
PKG_SHORTDESC="Khadas images upgrade"
PKG_SOURCE_NAME="images_upgrade-${PKG_VERSION}.tar.gz"
PKG_NEED_BUILD="NO"


make_host() {
	:
}

