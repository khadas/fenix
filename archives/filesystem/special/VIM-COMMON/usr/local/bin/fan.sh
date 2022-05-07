#!/bin/bash

RC=0
FAN_INPUT="${1:-"boot"}"

LINUX_VER=$(uname -r)
LINUX_VER="${LINUX_VER::3}"

if [ "${LINUX_VER}" == "4.9" ] || [ "${LINUX_VER}" == "5.4" ]; then
	FAN_MODE_NODE="/sys/class/fan/mode"
	FAN_LEVEL_NODE="/sys/class/fan/level"
	FAN_ENABLE_NODE="/sys/class/fan/enable"
	FAN_TEMP_NODE="/sys/class/fan/temp"
else
	FAN_CONTROL_NODE="/sys/class/thermal/thermal_zone0/trip_point_3_temp"
fi

AUTO_MODE=1
MANUAL_MODE=0

LEVEL_LOW=1
LEVEL_MID=2
LEVEL_HIGH=3

usage() {
	echo ""
	if [ "${LINUX_VER}" == "4.9" ] || [ "${LINUX_VER}" == "5.4" ]; then
		echo "Usage: $0 [on|auto|off]  :: Set fan mode"
		echo "       $0 [low|mid|high] :: Set fan level"
		echo "       $0 [temp]         :: Query cpu temperature"
		echo "       $0 [trig]         :: Query fan trigger temperature"
		echo "       $0 [mode]         :: Query fan mode/level"
	else
		echo "Usage: $0 [manual|auto]  :: Set fan mode"
	fi
	echo "       $0 [--help|-h]    :: This text"
	echo ""
	echo "Examp: $0 auto"
}

message() {
	local TYPE="$1"
	local TXT="$2"
	local RC="$3"
	echo "$TYPE $TXT"
	if [ "$TYPE" = "Error:" ] || [ "$TYPE" = "Help:" ]; then usage; fi
	logger -s "$TXT" "$RC" 1>/dev/null 2>&1
	exit $RC
}

# off
# auto
# low
# mid
# high
mode="auto"

# Require root privilege
#if [ $(id -u) != 0 ]; then
#   message "Error:" "Use sudo or run with root privilege!" 1
#fi

if [ "$FAN_INPUT" = "temp" ]; then
	mode=$FAN_INPUT
	FAN_TEMP=$(cat $FAN_TEMP_NODE | grep cpu_${FAN_INPUT} | cut -d':' -f2)
elif [ "$FAN_INPUT" = "trig" ]; then
	mode=$FAN_INPUT
	FAN_LVL_0=$(sudo cat /sys/class/fan/temp|grep level | awk '{print $4}' | cut -d':' -f2)
	FAN_LVL_1=$(sudo cat /sys/class/fan/temp|grep level | awk '{print $5}' | cut -d':' -f2)
	FAN_LVL_2=$(sudo cat /sys/class/fan/temp|grep level | awk '{print $6}' | cut -d':' -f2)
elif [ "$FAN_INPUT" = "mode" ]; then
	mode=$FAN_INPUT

	if [ ${LINUX_VER} == "4.9" ] || [ "${LINUX_VER}" == "5.4" ]; then
		FAN_MODE=$(cat $FAN_MODE_NODE | awk '{print $3}')
		FAN_LEVEL=$(cat $FAN_LEVEL_NODE | awk '{print $3}')
		FAN_STATE=$(cat $FAN_ENABLE_NODE | awk '{print $3}')

		if [ $FAN_MODE -eq 0 ]; then FAN_MODE=manual; else FAN_MODE=auto; fi
	
		case $FAN_STATE in
			0) FAN_STATE=inactive; mode=mode-off; ;;
			1) FAN_STATE=active ;;
		esac

		case $FAN_LEVEL in
			0) FAN_LEVEL=off ;;
			1) FAN_LEVEL=low ;;
			2) FAN_LEVEL=mid ;;
			3) FAN_LEVEL=high ;;
		esac
	else
		TEMP_VER=$(cat $FAN_CONTROL_NODE)
		if [ $TEMP_VER == "50000" ]; then
			FAN_MODE="auto"
		else
			FAN_MODE="manual"
		fi
	fi

elif [ "$FAN_INPUT" != "boot" ]; then
	mode=$FAN_INPUT
else {	
	for m in $(cat /proc/cmdline); do
		case ${m} in
			fan=*) mode=${m#*=} ;;
		esac
	done
	}
fi

case $mode in
	off)
		echo 0 > $FAN_ENABLE_NODE
		message "CAUTION:" "Disabling fan can reduce the lifetime of this board!" 0
		;;
	low)
		echo 1 > $FAN_ENABLE_NODE
		echo $MANUAL_MODE > $FAN_MODE_NODE
		echo $LEVEL_LOW > $FAN_LEVEL_NODE
		;;
	mid)
		echo 1 > $FAN_ENABLE_NODE
		echo $MANUAL_MODE > $FAN_MODE_NODE
		echo $LEVEL_MID > $FAN_LEVEL_NODE
		;;
	high)
		echo 1 > $FAN_ENABLE_NODE
		echo $MANUAL_MODE > $FAN_MODE_NODE
		echo $LEVEL_HIGH > $FAN_LEVEL_NODE
		;;
	on)
		echo $AUTO_MODE > $FAN_MODE_NODE
		echo 1 > $FAN_ENABLE_NODE
		;;
	auto)
		if [ "${LINUX_VER}" == "4.9" ] || [ "${LINUX_VER}" == "5.4" ]; then
			echo $AUTO_MODE > $FAN_MODE_NODE
			echo 1 > $FAN_ENABLE_NODE
		else
			echo 50000 > $FAN_CONTROL_NODE
		fi
		;;
	manual)
		echo 20000 > $FAN_CONTROL_NODE
		;;
	mode-off)
		echo "Fan state: $FAN_STATE"
		;;
	mode)
		if [ "${LINUX_VER}" == "4.9" ] || [ "${LINUX_VER}" == "5.4" ]; then
			echo "Fan mode: $FAN_MODE"
			echo "Fan level: $FAN_LEVEL"
			echo "Fan state: $FAN_STATE"
		else
			echo "Fan mode: $FAN_MODE"
		fi
		;;
	temp)
		echo "Fan temp: $FAN_TEMP"
		;;
	trig)
		echo "Fan trigger low temp: $FAN_LVL_0"
		echo "Fan trigger mid temp: $FAN_LVL_1"
		echo "Fan trigger high temp: $FAN_LVL_2"
		;;
	--help|-h) 
		message "Help:" "Command line parameters:" 0
		;;
	*)
		message "Error:" "Fan mode/level is unknown!" 2
		;;
esac

exit $RC
