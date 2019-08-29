#!/bin/bash

HDMI_STATUS="$1"

if [ "$HDMI_STATUS" == "HDMI=1" ]; then
	# HDMI plug in, setup HDMI
	/usr/local/bin/hdmi.sh $HDMI_STATUS
elif [ "$HDMI_STATUS" == "HDMI=0" ]; then
	# HDMI plug out, setup panel if exist

	if grep -q "panel_exist" /proc/cmdline; then
		tmp=$(cat /proc/cmdline)
		panel_exist="${tmp##*panel_exist=}"
		panel_exist="${panel_exist%% *}"
		if [ $panel_exist -eq 1 ]; then
			echo panel > /sys/class/display/mode

			fbset -fb /dev/fb0 -g 1088 1920 1088 3840 32
			echo "0 0 1087 1919" > /sys/class/graphics/fb0/free_scale_axis
			echo "0 0 1087 1919" > /sys/class/graphics/fb0/window_axis
			echo 0 > /sys/class/graphics/fb0/free_scale
			echo 1 > /sys/class/graphics/fb0/freescale_mode
		fi
	fi
fi

exit 0
