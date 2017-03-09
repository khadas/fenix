#!/bin/sh

fbset -fb /dev/fb0 -g 1920 1080 1920 2160 24
#echo 1080p60hz > /sys/class/display/mode

echo 0 > /sys/class/graphics/fb0/free_scale
echo 1 > /sys/class/graphics/fb0/freescale_mode
echo 0 0 1919 1079 > /sys/class/graphics/fb0/free_scale_axis
echo 0 0 1919 1079 > /sys/class/graphics/fb0/window_axis

echo 0 > /sys/class/graphics/fb1/free_scale
echo 1 > /sys/class/graphics/fb1/freescale_mode

echo 0 > /sys/class/graphics/fb0/blank
echo 0 > /sys/class/graphics/fb1/blank

# Setup LED: Heartbeat when bootup
echo heartbeat > /sys/class/leds/red/trigger
