#!/bin/sh

## hyphop ##

#= build debian mainline server raw image

# USAGE
#
#     ./script/make_debian_mainline_server[ ARGS]
#

export VENDOR=Amlogic
export LINUX=mainline
export UBOOT=mainline
export DISTRIBUTION=Debian
export DISTRIB_RELEASE=buster
export DISTRIB_TYPE=server
export DISTRIB_ARCH=arm64
export INSTALL_TYPE=SD-USB
export VERSION=0.8.3
#KHADAS_BOARD=

#NOCOMPRESS=
#NOMAKE=
xz=$(which xz)
CMP=-9

CMD(){
    echo "# $@">&2
    $@
}

CMD cd  "$(dirname $0)/.."

for l in build/linux-mainline-*; do
    CMD ln -sf $l linux 
    break
done

[ "$ARGS" ] || ARGS=$@
[ "$ARGS" ] || ARGS="VIM1 VIM2 VIM3 VIM3L"
echo "[i] build uboots: $ARGS">&2

for KHADAS_BOARD in $ARGS ; do

    export KHADAS_BOARD=$KHADAS_BOARD

    case $KHADAS_BOARD in
    *1)
    CHIP=S905X
    ;;
    *2)
    CHIP=S912
    ;;
    *3)
    CHIP=A311D
    ;;
    *3l|*3L)
    CHIP=S905D3
    ;;
    esac

    echo "[i] build $KHADAS_BOARD">&2
    export CHIP=$CHIP

    IMG=

    SCAN="${KHADAS_BOARD}_$DISTRIBUTION-$DISTRIB_TYPE-${DISTRIB_RELEASE}_"

    [ "$NOMAKE" ] || {
	make || exit 1
    }

    for IMG in build/images/$SCAN*.img; do
    [ -f $IMG ] || {
	echo "[e] image not found">&2
	exit 1
	break
    }
    done

    [ "$NOCOMPRESS" ] || {
	echo "[i] compress $IMG">&2
	[ "$xz" ] && {
	    ./scripts/xze $CMP $IMG
	}
    }

done

## END ##
