#!/bin/bash

# Delay 15S
count=15

TTY="/dev/tty1 /dev/ttyS0"
[ -c /dev/ttyFIQ0 ] && TTY="/dev/tty1 /dev/ttyFIQ0"

while true
do
	echo "Rebooting count $count" | tee $TTY > /dev/null
	sleep 1
	if [ $count -eq 0 ]; then
		break
	fi

	count=$((count - 1))
done

echo "Rebooting ..." | tee $TTY > /dev/null

sync
reboot reboot_test
