#!/bin/bash
resolutions_v=`edid-decode < /sys/class/amhdmitx/amhdmitx0/rawedid | sed -n '/Detailed mode/,/HorFreq:/p' | sed -n '1,5p' | sed -n '3p'  | awk '{print $1}'`
resolutions_h=`edid-decode < /sys/class/amhdmitx/amhdmitx0/rawedid | sed -n '/Detailed mode/,/HorFreq:/p' | sed -n '1,5p' | sed -n '2p'  | awk '{print $1}'`

hdmi.sh "${resolutions_h}x${resolutions_v}p60hz"
if [ $? -eq 0 ]
then
		exit 0
else
		hdmi.sh "${resolutions_v}p60hz" >/dev/null 2>&1
		if [ $? -ne 0 ]
		then
				hdmi.sh 720p60hz
				exit 0
		fi
fi
