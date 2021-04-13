#!/bin/bash

# Only for desktop
if ! which lightdm; then
	exit
fi

. /etc/fenix-release

FENIX=${VERSION}
LINUX=$(uname -r)
UBOOT=$(dpkg -l | grep "linux-u-boot" | awk '{print $3}')

zenity --info \
	   --title 'System Information' \
	   --text="<big><b>Fenix: <span foreground=\"yellow\">${FENIX}</span>\nLinux: <span foreground=\"yellow\">${LINUX}</span>\nU-boot: <span foreground=\"yellow\">${UBOOT}</span></b></big>" \
	   --window-icon=/etc/fenix/icons/systeminfo.png \
	   --width=250 \
	   --height=50

exit
