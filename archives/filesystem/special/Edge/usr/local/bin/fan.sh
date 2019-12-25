#!/bin/bash

FAN_LEVEL_NODE="/sys/class/thermal/cooling_device0/cur_state"
TEMP_NODE="/sys/class/thermal/thermal_zone0/temp"

TEMP_LOW=50000
TEMP_MID=60000
TEMP_HIGH=70000

AUTO_MODE=1
MANUAL_MODE=0

FAN_LEVEL_OFF=0
FAN_LEVEL_LOW=1
FAN_LEVEL_MID=2
FAN_LEVEL_HIGH=3

SLEEP_TIME=10

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

if [ -z $mode ]; then
	mode="auto"
fi

echo "FAN mode: $mode"

if [ "$mode" == "auto" ]; then
	TEMP=0
	TEMP_NEW=0
	LEVEL=$FAN_LEVEL_OFF
	LEVEL_NEW=0

	# Set FAN initial state
	echo $LEVEL > $FAN_LEVEL_NODE

	while true
	do
		sleep $SLEEP_TIME
		TEMP_NEW=`cat $TEMP_NODE`

		if [ $TEMP_NEW != $TEMP ]; then
			if [ $TEMP_NEW -ge $TEMP_HIGH ]; then
				LEVEL_NEW=$FAN_LEVEL_HIGH
			elif [ $TEMP_NEW -ge $TEMP_MID ]; then
				LEVEL_NEW=$FAN_LEVEL_MID
			elif [ $TEMP_NEW -ge $TEMP_LOW ]; then
				LEVEL_NEW=$FAN_LEVEL_LOW
			else
				LEVEL_NEW=$FAN_LEVEL_OFF
			fi

			if [ "$LEVEL_NEW" != "$LEVEL" ]; then
				echo $LEVEL_NEW > $FAN_LEVEL_NODE
				LEVEL=$LEVEL_NEW
			fi

			TEMP=$TEMP_NEW
		fi
	done
fi

case $mode in
	off)
		LEVEL=$FAN_LEVEL_OFF
		;;
	low)
		LEVEL=$FAN_LEVEL_LOW
		;;
	mid)
		LEVEL=$FAN_LEVEL_MID
		;;
	high)
		LEVEL=$FAN_LEVEL_HIGH
		;;
esac

echo $LEVEL > $FAN_LEVEL_NODE

exit 0
