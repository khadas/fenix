#!/bin/bash

STAN_VAL=100

if [ ! -f /sys/class/gpio/gpio105/direction ]; then
	echo 105 > /sys/class/gpio/export
fi
echo out > /sys/class/gpio/gpio105/direction

LINK_STATE=$(cat /sys/class/gpio/gpio105/value)

while true
do
	ADC_VAL=$(cat /sys/bus/iio/devices/iio:device0/in_voltage2_raw)
	if [ $STAN_VAL -gt $ADC_VAL ]; then
		if [ $LINK_STATE -ne 1 ]; then
			echo 1 > /sys/class/gpio/gpio105/value
			LINK_STATE=$(cat /sys/class/gpio/gpio105/value)
			echo "li"
		fi
	else
		if [ $LINK_STATE -eq 1 ]; then
			echo 0 > /sys/class/gpio/gpio105/value
			LINK_STATE=$(cat /sys/class/gpio/gpio105/value)
			echo "hao"
		fi
	fi

	sleep 1
done
