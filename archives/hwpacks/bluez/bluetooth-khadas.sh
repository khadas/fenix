#!/bin/bash

## Version cpomare
## $1 > $2  -  echo 1
## $2 < $2  -  echo -1
## $2 == $2 -  echo 0
version_compare() {
	if [ `echo "$@" | tr " " "\n" | sort -V | head -n 1` != "$1" ]; then
		echo 1
	elif  [ `echo "$@" | tr " " "\n" | sort -rV | head -n 1` != "$1" ]; then
		echo -1
	elif  [ `echo "$@" | tr " " "\n" | sort -V | head -n 1` == "$1" ]; then
		echo 0
	fi
}

if cat /proc/device-tree/compatible | grep rockchip > /dev/null; then
	vender="Rockchip"
elif cat /proc/device-tree/compatible | grep amlogic > /dev/null; then
	vender="Amlogic"
else
	echo "Error: Unsupported vender!"
	exit -1
fi

echo "VENDER: $vender"

linux_ver=`uname -a | awk '{print $3}'`

if [ "$vender" == "Amlogic" ]; then
	ret=`version_compare $linux_ver "4.12"`

	# version >= 4.12
	if [ $ret == 1 ] || [ $ret == 0 ];then
		## Supported mainline
		model=`cat /sys/bus/mmc/devices/mmc2\:0001/mmc2\:0001\:1/device`
		bt_tty="ttyAML1"
	else
		model=`cat /sys/bus/mmc/devices/sdio:0001/sdio:0001:1/device`
		bt_tty="ttyS1"
	fi

elif [ "$vender" == "Rockchip" ]; then
	model=`cat /sys/bus/mmc/devices/mmc2\:0001/mmc2\:0001\:1/device`
	bt_tty="ttyS0"
fi

/bin/echo 0 > /sys/class/rfkill/rfkill0/state
/bin/sleep 2
/bin/echo 1 > /sys/class/rfkill/rfkill0/state

# Load the firmware
if [ "$model" = "0xa9bf" ]; then
    # VIM Pro
	/usr/local/bin/brcm_patchram_plus --patchram /lib/firmware/brcm/BCM4345C0.hcd  --no2bytes --tosleep 1000 /dev/$bt_tty
elif [ "$model" = "0xa9a6" ]; then
    # VIM
	/usr/local/bin/brcm_patchram_plus --patchram /lib/firmware/brcm/bcm43438a1.hcd  --no2bytes --tosleep 1000 /dev/$bt_tty
elif [ "$model" = "0x4356" ]; then
	# VIM2
	/usr/local/bin/brcm_patchram_plus  --patchram /lib/firmware/brcm/bcm4356a2.hcd --no2bytes --tosleep 1000 /dev/$bt_tty
elif [ "$model" = "0x4359" ]; then
	# VIM2 Pro & Edge AP6398S
	/usr/local/bin/brcm_patchram_plus  --patchram /lib/firmware/brcm/BCM4359C0.hcd --no2bytes --tosleep 1000 /dev/$bt_tty
fi

# FIXME Delay
/bin/sleep 1

# Attach HCI adapter
/usr/bin/hciattach /dev/$bt_tty any
