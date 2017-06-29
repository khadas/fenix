#!/bin/sh

model=`cat /sys/bus/mmc/devices/sdio:0001/sdio:0001:1/device`

# Load the firmware
if [ "$model" = "0xa9bf" ]; then
    # VIM Pro
	/usr/local/bin/brcm_patchram_plus --patchram /lib/firmware/brcm/BCM4345C0.hcd  --no2bytes --tosleep 1000 /dev/ttyS1
elif [ "$model" = "0xa9a6" ]; then
    # VIM
	/usr/local/bin/brcm_patchram_plus --patchram /lib/firmware/brcm/bcm43438a1.hcd  --no2bytes --tosleep 1000 /dev/ttyS1
elif [ "$model" = "0x4356" ]; then
	# VIM2
	/usr/local/bin/brcm_patchram_plus  --patchram /lib/firmware/brcm/bcm4356a2.hcd --no2bytes --tosleep 1000 /dev/ttyS1
fi

# FIXME Delay
/bin/sleep 1

# Attach HCI adapter
/usr/bin/hciattach /dev/ttyS1 any
