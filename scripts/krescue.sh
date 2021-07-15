#!/bin/bash

## hyphop ##

#= build krescue script

set -e -o pipefail

help(){ echo "USAGE: $0 [build|write|help]
"
}

cd ${0%/*}/..
. config/config

[ "$KRESCUE" ] || \
	KRESCUE=krescue

KRESCUE_SDK=khadas-rescue-sdk
KRESCUE_GIT_SDK=https://github.com/khadas/$KRESCUE_SDK

FENIX_BUILD=$BUILD

cd $FENIX_BUILD

mkdir -p $KRESCUE && cd $KRESCUE

git -C $KRESCUE_SDK branch --show-current 1>/dev/null || \
	git clone $KRESCUE_GIT_SDK

cd $KRESCUE_SDK

KRESCUE_BUILD=../$KRESCUE-build
KRESCUE_IMAGES=$KRESCUE_BUILD/krescue-images

[ "$ACTION" ] || \
	ACTION=$1

[ "$KRESCUE_IMAGE_TARGET" ] || \
	KRESCUE_IMAGE_TARGET=-a

case $ACTION in
	*write-vim1)
	KHADAS_BOARD=VIM1
	;;
	*write-vim2)
	KHADAS_BOARD=VIM2
	;;
	*write-vim3)
	KHADAS_BOARD=VIM3
	;;
	*write-vim3l)
	KHADAS_BOARD=VIM3L
	;;
	*write-edge)
	KHADAS_BOARD=Edge
	;;
esac

case $ACTION in
	*write*)
	echo "[i] Krescue write $KHADAS_BOARD image to ..."
	[ ! "$KHADAS_BOARD" ] && \
		echo  "[e] KHADAS_BOARD undefined" && exit 1

	KRESCUE_IMAGE=$KRESCUE_IMAGES/$KHADAS_BOARD.krescue.sd.img.gz

	[ ! -e "$KRESCUE_IMAGE" ] && \
		echo "[e] $KRESCUE_IMAGE image not found
	Build krescue at 1st \`make krescue\`" && exit 1

	./scripts/image2sd.sh \
		$KRESCUE_IMAGE $KRESCUE_IMAGE_TARGET
	;;
	build|krescue)
	echo "[i] Krescue build/rebuild images"
	./scripts/prepare || echo no possible continue with errors
	BUILD=$KRESCUE_BUILD ./scripts/build -c -u -y # replace old images + git update + ask yes
	;;
	*)
	help
	;;
esac
