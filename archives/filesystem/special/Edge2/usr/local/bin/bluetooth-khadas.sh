#!/bin/bash

#/bin/echo 0 > /sys/class/rfkill/rfkill0/state
#/bin/sleep 2
#/bin/echo 1 > /sys/class/rfkill/rfkill0/state
#/bin/sleep 2

#/usr/local/bin/brcm_patchram_plus --no2bytes --use_baudrate_for_download  --tosleep  200000 --baudrate 1500000 --patchram /lib/firmware/brcm/BCM4359C0.hcd /dev/ttyS0

/usr/sbin/rfkill block 0
/bin/sleep 1
/usr/sbin/rfkill unblock 0
/bin/sleep 1

/usr/local/bin/hciattach -n -s 115200 /dev/ttyS9 bcm43xx 1500000
