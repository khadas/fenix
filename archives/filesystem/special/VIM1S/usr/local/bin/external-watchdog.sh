#!/bin/bash


case "$1" in
	start|restart)
		echo 464 | tee /sys/class/gpio/export
		echo out | tee /sys/class/gpio/gpio464/direction
		echo 1 | tee /sys/class/gpio/gpio464/value

		i2cset -f -y 1 0x18 0x8B 1

		while :
		do
			echo 1 | tee /sys/class/gpio/gpio464/value
			sleep 0.5
			echo 0 | tee /sys/class/gpio/gpio464/value
			sleep 0.5
		done
		;;
	stop)
		i2cset -f -y 1 0x18 0x8B 0
		sleep 0.1
		i2cset -f -y 1 0x18 0x8B 0
		sleep 0.1
		i2cset -f -y 1 0x18 0x8B 0
		;;
esac

exit $?
