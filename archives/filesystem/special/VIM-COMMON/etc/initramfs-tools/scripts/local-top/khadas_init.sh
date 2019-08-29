#!/bin/sh

if [ "$(stat -c %d:%i /)" != "$(stat -c %d:%i /proc/1/root/.)" ]; then
	echo "$0: Running in chroot, ignore it!"
	exit 0
fi

panel_exist=0

for x in $(cat /proc/cmdline); do
	case ${x} in
		m_bpp=*)
			bpp=${x#*=}
			;;
		vout=*)
			vout=${x#*=}
			;;
		panel_exist=*)
			panel_exist=${x#*=}
			;;
	esac
done

display_device=`echo $vout | awk -F ',' '{print $1}'`

if [ $panel_exist -eq 1 ] && [ $display_device = panel ]; then

	#echo null > /sys/class/display/mode

	echo panel > /sys/class/display/mode

	fbset -fb /dev/fb0 -g 1088 1920 1088 3840 32

	echo "0 0 1087 1919" > /sys/class/graphics/fb0/free_scale_axis
	echo "0 0 1087 1919" > /sys/class/graphics/fb0/window_axis
	echo 0 > /sys/class/graphics/fb0/free_scale
	echo 1 > /sys/class/graphics/fb0/freescale_mode
else
	bpp=32
	mode=720p60hz

	fbset -fb /dev/fb0 -g 1280 720 1280 1440 $bpp
	echo $mode > /sys/class/display/mode
	echo 0 > /sys/class/graphics/fb0/free_scale
	echo 1 > /sys/class/graphics/fb0/freescale_mode
	echo 0 0 1279 719 > /sys/class/graphics/fb0/free_scale_axis
	echo 0 0 1279 719 > /sys/class/graphics/fb0/window_axis
	echo 0 > /sys/class/graphics/fb0/free_scale
	echo 1 > /sys/class/graphics/fb0/freescale_mode
fi

# Enable framebuffer device
echo 0 > /sys/class/graphics/fb0/blank

# Blank fb1 to prevent static noise
echo 1 > /sys/class/graphics/fb1/blank

echo 1 > /sys/devices/virtual/graphics/fbcon/cursor_blink
