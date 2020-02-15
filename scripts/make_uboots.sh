#!/bin/sh

## hyphop ##

#= build uboot for VIMx boards

# USAGE
#
#     ./script/make_uboots.sh [VIM1] [VIM2] [VIM3] [VIM3L]
#

export VENDOR=Amlogic
export LINUX=mainline
export UBOOT=mainline
export DISTRIBUTION=Ubuntu
export DISTRIB_RELEASE=bionic
export DISTRIB_TYPE=server
export DISTRIB_ARCH=arm64
export INSTALL_TYPE=SD-USB

DST=/tmp/uboot-mainline

[ -d "$DST" ] ||  mkdir -p "$DST"

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
    *3l)
    CHIP=S905D3
    ;;
    esac

    echo "[i] build $KHADAS_BOARD">&2
    export CHIP=$CHIP

    make uboot || exit 1

    cp build/u-boot-mainline*/fip/u-boot.bin \
	$DST/u-boot.$KHADAS_BOARD.bin
    cp build/u-boot-mainline*/fip/u-boot.bin.sd.bin \
	$DST/u-boot.$KHADAS_BOARD.sd.bin

#   exit 0

done

## END ##