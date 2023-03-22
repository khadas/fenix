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
		panel_type=*)
			panel_type=${x#*=}
			;;
	esac
done

display_device=`echo $vout | awk -F ',' '{print $1}'`

if [ $panel_exist -eq 1 ] && [ $display_device = panel ]; then

	#echo null > /sys/class/display/mode

	echo panel > /sys/class/display/mode
	if [ $panel_type = lcd_2 ]; then
		fbset -fb /dev/fb0 -g 1920 1200 1920 2400 32

		echo "0 0 1919 1119" > /sys/class/graphics/fb0/free_scale_axis
		echo "0 0 1919 1119" > /sys/class/graphics/fb0/window_axis

	else
		fbset -fb /dev/fb0 -g 1088 1920 1088 3840 32

		echo "0 0 1087 1919" > /sys/class/graphics/fb0/free_scale_axis
		echo "0 0 1087 1919" > /sys/class/graphics/fb0/window_axis

	fi

	echo 0 > /sys/class/graphics/fb0/free_scale
	echo 1 > /sys/class/graphics/fb0/freescale_mode
fi

# Enable framebuffer device
echo 0 > /sys/class/graphics/fb0/blank

# Blank fb1 to prevent static noise
echo 1 > /sys/class/graphics/fb1/blank

echo 0 > /sys/devices/virtual/graphics/fbcon/cursor_blink
