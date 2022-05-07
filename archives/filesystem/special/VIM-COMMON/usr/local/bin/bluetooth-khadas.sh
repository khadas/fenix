#!/bin/bash

linux_ver=`uname -a | awk '{print $3}'`

if linux-version compare $linux_ver ge 5.10; then
	## Mainline kernel
	bt_tty="ttyAML1"

	exit 0
else
	## Legacy kernel
	bt_tty="ttyS1"
fi

/usr/sbin/rfkill block 0
/bin/sleep 2
/usr/sbin/rfkill unblock 0

# FIXME Delay
/bin/sleep 1

# Attach HCI adapter
/usr/local/bin/hciattach -n -s 115200 /dev/$bt_tty bcm43xx 2000000
