#!/bin/bash

LINUX_VER=`uname -r`
if [ ${LINUX_VER::3} == "4.9" ] || [ -f /boot/.next ]; then
	exit
fi

if systemctl is-enabled resize2fs.service | grep "^enabled$" > /dev/null; then
	exit
fi

if [ ! -d /usr/share/desktop-base ]; then
	## For server
	drm-setcrtc -d meson -s 0 > /dev/null 2>&1
	sleep 0.5
	echo 1 > /sys/class/graphics/fb0/blank
	sleep 0.5
	echo 0 > /sys/class/graphics/fb0/blank
else
	## For desktop
	## Restart the GDM service when hdmitx plugin

	process_name="gdm-wayland-session"
	search_string="/usr/libexec/gdm-wayland-session"

	output=$(ps aux | grep "$process_name")
	if ! echo "$output" | grep -q "$search_string"; then
		systemctl restart gdm3
	fi
fi

exit
