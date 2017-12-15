#!/bin/sh

T_AUTO=true

T_MIN=30000
T_MIDI=60000
T_MAX=70000

TIMER_SEC=2
TIMER_W=2

K_VER=`uname -r`

if [ $K_VER = "3.14.29" ]; then
    echo "kernel 3.14.29"
    PIN1=218
    PIN2=219
elif [ $K_VER = "4.9.26" ]; then
    echo "kernel 4.9.26"
    PIN1=73
    PIN2=74
elif [ $K_VER = "4.9.40" ]; then
    echo "kernel 4.9.40"
    PIN1=74
    PIN2=75
fi

echo $PIN1 > /sys/class/gpio/export
echo $PIN2 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$PIN1/direction
echo out > /sys/class/gpio/gpio$PIN2/direction

#test fan
# enable min
echo 1 > /sys/class/gpio/gpio$PIN1/value 
echo 0 > /sys/class/gpio/gpio$PIN2/value 
sleep 2
# enable midi
echo 0 > /sys/class/gpio/gpio$PIN1/value 
echo 1 > /sys/class/gpio/gpio$PIN2/value 
sleep 2
# enable max
echo 1 > /sys/class/gpio/gpio$PIN1/value 
echo 1 > /sys/class/gpio/gpio$PIN2/value 
sleep 2
# stop
echo 0 > /sys/class/gpio/gpio$PIN1/value 
echo 0 > /sys/class/gpio/gpio$PIN2/value 
sleep 2

if [ $T_AUTO = true ]; then

K_TEMPER=`cat /sys/class/thermal/thermal_zone0/temp`
#echo "Start " $K_TEMPER

while true
do
    sleep $TIMER_SEC
    K_TEMPER_NEW=`cat /sys/class/thermal/thermal_zone0/temp`
#    echo $K_TEMPER_NEW

    if [ $K_TEMPER_NEW != $K_TEMPER ]; then
	if [ $K_TEMPER_NEW -ge $T_MAX ]; then
	    echo 1 > /sys/class/gpio/gpio$PIN1/value 
	    echo 1 > /sys/class/gpio/gpio$PIN2/value 
	    K_TEMPER=$K_TEMPER_NEW
	    sleep $TIMER_W
	elif [ $K_TEMPER_NEW -ge $T_MIDI ]; then
	    echo 0 > /sys/class/gpio/gpio$PIN1/value 
	    echo 1 > /sys/class/gpio/gpio$PIN2/value 
	    K_TEMPER=$K_TEMPER_NEW
	    sleep $TIMER_W
	elif [ $K_TEMPER_NEW -ge $T_MIN ]; then
	    echo 1 > /sys/class/gpio/gpio$PIN1/value 
	    echo 0 > /sys/class/gpio/gpio$PIN2/value 
	    K_TEMPER=$K_TEMPER_NEW
	    sleep $TIMER_W
	else
	    echo 0 > /sys/class/gpio/gpio$PIN1/value 
	    echo 0 > /sys/class/gpio/gpio$PIN2/value 
	    K_TEMPER=$K_TEMPER_NEW
	    sleep $TIMER_W
	fi
    fi
done

fi
