#!/bin/bash

## hyphop ##

#= write image to board

help() { echo "\
USAGE EXAMPLE

Write image into device storage (device must be connected at same network)

     make write                     # write image to eMMC
     WRITE_DST=nvme make write      # to nvme
     WRITE_DST=sd   make write      # to sd
     WRITE_DST=usb  make write      # to usb
     make write-boot-online         # update uboot areas online

     WRITE_ARGS=nvme make all write # complex fenix make image and write into device

Network: board must be reachable by krescue.local host name

USAGE: [ARGS] $0 [ write | write-boot-online | help ]
"
}

set -e -o pipefail

cd ${0%/*}/..
source config/config

need_='Build it at 1st! `source setenv.sh && make` or `IMAGE=path_to_image make`'

[ ! "$KHADAS_BOARD" ] && echo "[e] $need_" && exit 1

source $BOARD_CONFIG/$KHADAS_BOARD.conf
#source config/functions/functions

[ "$IMAGE" ] || \
IMAGE="$BUILD_IMAGES/$IMAGE_FILE_NAME"

[ "$ACTON" ] ||
	ACTION=$1

note_(){
	echo "NOTE:	start Krescue before use it"
}

case $ACTION in
	write)
	echo "[i] $ACTION image $IMAGE"
	[ ! -e "$IMAGE" ] && \
	echo "[e] $IMAGE image not found
	$need_" && exit 1
	note_
	echo "curl krescue.local/shell/write | sh -s - $IMAGE $WRITE_DST"
	curl krescue.local/shell/write | sh -s - $IMAGE $WRITE_DST
	;;
	write-boot-online|write-boot-emmc-online|write-boot-spi-online|write-boot-spi-online-apply)
	echo "[i] $ACTION "
	note_
	echo "curl krescue.local/shell/write | sh -s - /dev/null ${ACTION#write}"
	curl krescue.local/shell/write | sh -s - /dev/null ${ACTION#write}
	;;
	""|help)
	help
	note_
	;;
esac
