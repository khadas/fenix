#!/bin/sh

linux_version=`uname -r`

if linux-version compare $linux_version ge 5.6; then
	# ignore for mainline kernel
	echo "Ignore for mainline kernel..."
	exit 0
fi

for x in $(cat /proc/cmdline); do
	case ${x} in
		m_bpp=*)
			bpp=${x#*=}
			;;
		vout=*)=
			vout=${x#*=}
			;;
		panel_exist=*)
			panel_exist=${x#*=}
			;;
	 esac
done

display_device=`echo $vout | awk -F ',' '{print $1}'`

#if [ $panel_exist -eq 1 ] && [ $display_device = panel ]; then
if [ $display_device = panel ]; then
#      echo null > /sys/class/display/mode

#      echo panel > /sys/class/display/mode

	fbset -fb /dev/fb0 -g 1080 1920 1080 3840 32

	echo "0 0 1079 1919" > /sys/class/graphics/fb0/free_scale_axis
	echo "0 0 1079 1919" > /sys/class/graphics/fb0/window_axis
	echo 0 > /sys/class/graphics/fb0/free_scale
	echo 1 > /sys/class/graphics/fb0/freescale_mode

	# Enable framebuffer device
	echo 0 > /sys/class/graphics/fb0/blank

	# Blank fb1 to prevent static noise
	echo 1 > /sys/class/graphics/fb1/blank

	if ! which lightdm; then
		echo 1 > /sys/devices/virtual/graphics/fbcon/cursor_blink
	else
		echo 0 > /sys/devices/virtual/graphics/fbcon/cursor_blink
	fi
fi

exit

