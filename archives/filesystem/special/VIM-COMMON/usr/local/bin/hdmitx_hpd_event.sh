#!/bin/bash

LINUX_VER=`uname -r`
if [ ${LINUX_VER::3} == "4.9" ] || [ -f /boot/.next ]; then
	exit
fi

if systemctl is-enabled resize2fs.service | grep "^enabled$" > /dev/null; then
	exit
fi

if ! (systemctl is-active --quiet display-manager.service); then
	## For server
	## Get hdmi resolution
	for x in $(cat /proc/cmdline); do
		case ${x} in
			hdmimode=*)
				hdmimode=${x#*=}
			;;
		esac
	done

	if [ $hdmimode == none ]; then
		drm-setcrtc -d meson -s 0 > /dev/null 2>&1
	else
		drm-setcrtc -d meson -m ${hdmimode} -s 0 > /dev/null 2>&1
	fi
	sleep 0.5
	echo 1 > /sys/class/graphics/fb0/blank
	sleep 0.5
	echo 0 > /sys/class/graphics/fb0/blank
else
	## For desktop
	## Restart the display manager (gdm3 or lightdm) when hdmitx plugin

	systemctl reload-or-restart display-manager.service
fi

exit
