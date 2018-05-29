#!/bin/sh

FAN_ENABLE_NODE="/sys/class/fan/enable"
FAN_MODE_NODE="/sys/class/fan/mode"
FAN_LEVEL_NODE="/sys/class/fan/level"

AUTO_MODE=1
MANUAL_MODE=0

LEVEL_LOW=1
LEVEL_MID=2
LEVEL_HIGH=3

# off
# auto
# low
# mid
# high
mode="auto"

for m in $(cat /proc/cmdline); do
	case ${m} in
		fan=*) mode=${m#*=} ;;
	esac
done

case $mode in
	off)
		echo 0 > $FAN_ENABLE_NODE
		;;
	low)
		echo $LEVEL_LOW > $FAN_LEVEL_NODE
		echo $MANUAL_MODE > $FAN_MODE_NODE
		echo 1 > $FAN_ENABLE_NODE
		;;
	mid)
		echo $LEVEL_MID > $FAN_LEVEL_NODE
		echo $MANUAL_MODE > $FAN_MODE_NODE
		echo 1 > $FAN_ENABLE_NODE
		;;
	high)
		echo $LEVEL_HIGH > $FAN_LEVEL_NODE
		echo $MANUAL_MODE > $FAN_MODE_NODE
		echo 1 > $FAN_ENABLE_NODE
		;;
	auto)
		echo $AUTO_MODE > $FAN_MODE_NODE
		echo 1 > $FAN_ENABLE_NODE
		;;
esac

exit 0
