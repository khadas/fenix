#!/bin/bash

STAN_VAL=100

if [ ! -f /sys/class/gpio/gpio105/direction ]; then
	echo 105 > /sys/class/gpio/export
fi
echo out > /sys/class/gpio/gpio105/direction

STATION_STATE=0

while true
do
	LINK_STATE=$(cat /sys/bus/iio/devices/iio:device0/in_voltage2_raw)
	if [ $STAN_VAL -gt $LINK_STATE ]; then
		if [ $STATION_STATE -ne 1 ]; then
			echo 1 > /sys/class/gpio/gpio105/value
			STATION_STATE=1
		fi
	else
		if [ $STATION_STATE -eq 1 ]; then
			echo 0 > /sys/class/gpio/gpio105/value
			STATION_STATE=0
		fi
	fi

	sleep 1
done
