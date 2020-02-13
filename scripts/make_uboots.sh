#!/bin/sh

## hyphop ##

#= build uboot for VIMx boards

VENDOR=Amlogic
LINUX=mainline
UBOOT=mainline
DISTRIBUTION=Ubuntu
DISTRIB_RELEASE=bionic
DISTRIB_TYPE=server
DISTRIB_ARCH=arm64
INSTALL_TYPE=SD-USB

DST=/tmp/uboot-mainline

[ -d "$DST" ] ||  mkdir -p "$DST"

for KHADAS_BOARD in VIM1 VIM2 VIM3 VIM3L; do

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

    make uboot

    cp build/u-boot-mainline*/fip/u-boot.bin \
	$DST/u-boot.$KHADAS_BOARD.bin
    cp build/u-boot-mainline*/fip/u-boot.bin.sd.bin \
	$DST/u-boot.$KHADAS_BOARD.sd.bin

    exit 0

done

