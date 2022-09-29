#!/bin/bash

systemctl restart bluetooth-khadas

sleep 3

id=$(rfkill list | grep hci0 | awk -F ":" '{print $1}')
rfkill unblock $id

if ps -ef | grep "blueman-manager" | grep -q -v "grep"; then
	killall -9 "blueman-manager"
fi

exit 0
