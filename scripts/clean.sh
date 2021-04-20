#!/bin/bash

set -e -o pipefail

# USAGE: [CLEAN_ALL=1] [CLEAN_DOWNLOAD=1] clean.sh
#  default (no params) -
#  CLEAN_ALL           - clean all = remove all build + downloads + vendor linux/uboot dirs
#  CLEAN_DOWNLOAD      - default clean + download dir
#  CLEAN_CCACHE_ONLY   - remove only ccache
#  CLEAN_OLD_ONLY      - clean last terminated build session

## Parameters
export NO_CCACHE=yes
export CCACHE_QUIET=yes

cd ${0%/*}/..
source config/config
## Functions
source config/functions/functions
#################################################################

check_active_session

[ "$CLEAN_CCACHE_ONLY" ] && {
    info_msg "CLEAN_CCACHE by path $CCACHE_DIR"
    if [ "$CCACHE_DIR" -a -d "$CCACHE_DIR" ]; then
	rm -rf "$CCACHE_DIR"
    else
	info_msg "CCACHE_DIR: $CCACHE_DIR missed or empty"
    fi
    exit
}

need_sudo || true

[ "$CLEAN_OLD_ONLY" ] && {
    clean_old_session
    exit
}

[ -d "$BUILD" ] && {
## Cleanup build images
info_msg  "Cleanup build images... => $BUILD"

[ "$CLEAN_ALL" ] && \
info_msg  "CLEAN_ALL mode enabled"
[ "$CLEAN_DOWNLOAD" ] && \
info_msg  "CLEAN_DOWNLOAD mode enabled"

unmount_deep -v "$BUILD"
cd "$BUILD"
find -maxdepth 1 -printf '%P\n' | while read l ; do
 [ "$l" ] || continue
 [ -d "$l/.git" -a ! "$CLEAN_ALL" ] && {
   info_msg  "Have Git! Ignore $l"
   continue
 }
 $sudo rm -rf "$l"
done
cd - >/dev/null
}

# may be no need it ????
[ "$CLEAN_DOWNLOAD" -o "$CLEAN_ALL" ] && {
[ -d "$DOWNLOAD_PKG_DIR" ] && {
info_msg "Cleanup Downloads... => $DOWNLOAD_PKG_DIR"
rm -rf "$DOWNLOAD_PKG_DIR"
}
}

## Cleanup vendor U-Boot

[ -d "$UBOOT_VENDOR_DIR" ] && {
info_msg "Cleanup U-Boot... => $UBOOT_VENDOR_DIR"
if [ -s "$UBOOT_VENDOR_DIR/Makefile" ] ; then
#make -j8 CROSS_COMPILE=aarch64-linux-gnu- distclean -C"$UBOOT_VENDOR_DIR"
make -j8 distclean -C"$UBOOT_VENDOR_DIR"
else
rm -rf "$UBOOT_VENDOR_DIR"
fi
}

## Cleanup vendor Linux
[ -d "$LINUX_VENDOR_DIR" ] && {
info_msg "Cleanup Linux... => $LINUX_VENDOR_DIR"
if [ -s "$LINUX_VENDOR_DIR/Makefile" ] ; then
make -j8 ARCH=arm64 distclean -C"$LINUX_VENDOR_DIR"
else
rm -rf "$LINUX_VENDOR_DIR"
fi
}

echo -e "\nDone."
echo -e "\n`date`"
