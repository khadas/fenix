PKG_NAME="qemu"
PKG_VERSION="5.0.0-rc1"
PKG_SHA256="cfd6b2dd9fb3363d45efd5251b21c544879a562de3b980489b686dcbd2b6d580"
PKG_SOURCE_DIR="$PKG_NAME-$PKG_VERSION"
PKG_SITE="https://download.qemu.org"
PKG_SOURCE_NAME="$PKG_SOURCE_DIR.tar.xz"
PKG_URL="$PKG_SITE/$PKG_SOURCE_NAME"
PKG_ARCH="x86"
PKG_LICENSE="GPL"
PKG_SHORTDESC="QEMU is a generic and open source machine emulator and virtualizer."
PKG_NEED_BUILD="YES"


make_host() {

    ./configure \
    --static \
    --disable-slirp \
    --disable-system \
    --target-list=aarch64-linux-user \
    --disable-fdt \
    --disable-libnfs \
    --disable-bzip2

#    --prefix=/tmp/qemu-user-static \
#    --enable-linux-user

    make -j${NR_JOBS}

}

makeinstall_host() {

    [ -d ../qemu ] || mkdir ../qemu
    cp aarch64-linux-user/qemu-aarch64 ../qemu/$QEMU_BINARY
    rm -rf *

}