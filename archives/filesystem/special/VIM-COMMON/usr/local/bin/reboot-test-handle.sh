#!/bin/bash

# Delay 15S
count=15

while true
do
	echo "Rebooting count $count" > /dev/tty1
	sleep 1
	if [ $count -eq 0 ]; then
		break
	fi

	count=$((count - 1))
done

echo "Rebooting ..." > /dev/tty1

sync
reboot -f reboot_test
