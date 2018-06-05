PKG_NAME="gcc-linaro-aarch64-elf"
PKG_VERSION="7.2.1-2017.11"
PKG_VERSION_SHORT="7.2-2017.11"
PKG_SHA256="30fb7d876bcb982c502057c593d9c1f11b35d5158a26d986718e2b998388c4c8"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE=""
PKG_URL="https://releases.linaro.org/components/toolchain/binaries/${PKG_VERSION_SHORT}/aarch64-elf/gcc-linaro-${PKG_VERSION}-x86_64_aarch64-elf.tar.xz"
PKG_SOURCE_DIR="gcc-linaro-${PKG_VERSION}-x86_64_aarch64-elf"
PKG_SOURCE_NAME="$(basename $PKG_URL)"
PKG_SHA256=""
PKG_NEED_BUILD="NO"
PKG_SHORTDESC="GCC for building mainline U-Boot"

makeinstall_host() {
	mkdir -p $TOOLCHAINS/gcc-linaro-aarch64-elf/
	rm -rf $TOOLCHAINS/gcc-linaro-aarch64-elf/*
	cp -a * $TOOLCHAINS/gcc-linaro-aarch64-elf
}
