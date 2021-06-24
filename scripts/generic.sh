#!/bin/sh

#= customize iamge on last stage

## USAGE EXAMPLES

#
#  CUSTOM_SCRIPT=$PWD/scripts/generic.sh NO_GIT_UPDATE=1 make image
#

echo CUSTOM SCRIPT "$@"

echo "IMAGE_FILE_NAME=$IMAGE_FILE_NAME"
echo "BUILD_IMAGES=$BUILD_IMAGES"

ROOT="$PWD"

#env

IMG="$BUILD_IMAGES/$IMAGE_FILE_NAME"

[ -e "$IMG" ] || {
    echo "[i] skip it ! image not found $IMG"
    exit 0
}

IMG_INFO=$(file $IMG)

#S=$(losetup -a -l | grep $IMG)

echo "> $IMG_INFO"
MNT=
i=0
P=/tmp/fenix.image.part
o=
o1=

for v in $IMG_INFO; do
    case $v in
	startsector)
	ss=1
	;;
	sectors*)
	o=${o%,}
	[ "$o1" ] || o1=$o
	echo "part $i > $o + $s"
	M=$P.$i
	mkdir -p $M
	MNT="$MNT $M"
	i=$((i+1))
	echo mount -o offset=$((o*512)),sizelimit=$((s*512)) "$IMG" "$M"
	mount -o offset=$((o*512)),sizelimit=$((s*512)) "$IMG" "$M"
	;;
	*)
	[ "$ss" ] && o=$v && ss=
	s=$v
	;;
    esac
done

#env

cp="rsync -avz --no-o --no-g --no-perms"

(
    cd $P.0/ || exit 1

    rm -rf boot* aml* s9*

    case $IMAGE_FILE_NAME in
	Edge*)
	echo Edge Custom
	;;
	VIM*)
	echo VIM Custom
	;;
    esac

    $cp $ROOT/archives/filesystem/special/Generic/boot/extlinux .

    ls -l1
)


LOOPS=$(losetup -a -l | grep $IMG)

for loop1 in $(echo "$LOOPS" | grep $((o1*512))); do
    echo "1: $loop1"
    break
done

for loop2 in $(echo "$LOOPS" | grep $((o*512))); do
    echo "2: $loop2"
    break
done

(
    cd $P.1/ || exit 1

#   $cp $ROOT/archives/filesystem/common/etc/initramfs-tools etc/

    ls -l1 etc/initramfs-tools
    head etc/initramfs-tools/initramfs.conf
#    mkdir -p var/lib/alsa
#    $cp $ROOT/archives/filesystem/blobs/asound.state/asound.state var/lib/alsa/

)

# optimize
mount -o remount,ro $loop2
echo zerofree -v $loop2
zerofree -v $loop2

for m in $MNT; do
    echo "umount $m"
    umount -d $m
done

exit 0