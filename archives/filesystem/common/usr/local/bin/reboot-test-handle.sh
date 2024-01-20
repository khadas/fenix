#!/bin/bash

# Delay 15S
count=15

while true
do
	echo "Rebooting count $count" | tee /dev/tty1 /dev/ttyS0 > /dev/null
	sleep 1
	if [ $count -eq 0 ]; then
		break
	fi

	count=$((count - 1))
done

echo "Rebooting ..." | tee /dev/tty1 /dev/ttyS0 > /dev/null

sync
reboot reboot_test
