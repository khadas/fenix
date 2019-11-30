#!/bin/sh


hpd_state=`cat /sys/class/amhdmitx/amhdmitx0/hpd_state`
#bpp=24
bpp=32
mode=${1:-720p60hz}
#mode=2160p60hz
#mode=720p60hz

if [ $hpd_state -eq 0 ]; then
	# Exit if HDMI cable is not connected
	exit 0
fi

common_display_setup() {
	M="0 0 $(($X - 1)) $(($Y - 1))"
	Y_VIRT=$(($Y * 2))
	fbset -fb /dev/fb0 -g $X $Y $X $Y_VIRT $bpp
	echo null > /sys/class/display/mode
	echo $mode > /sys/class/display/mode
	echo $M > /sys/class/graphics/fb0/free_scale_axis
	echo $M > /sys/class/graphics/fb0/window_axis

	echo 0 > /sys/class/graphics/fb0/free_scale
	echo 1 > /sys/class/graphics/fb0/freescale_mode
}

case $mode in
	480*)
		export X=720
		export Y=480
		;;
	576*)
		export X=720
		export Y=576
		;;
	720p*)
		export X=1280
		export Y=720
		;;
	1080*)
		export X=1920
		export Y=1080
		;;
	2160p*)
		export X=3840
		export Y=2160
		;;
	smpte24hz*)
		export X=3840
		export Y=2160
		;;
	640x480p60hz*)
		export X=640
		export Y=480
		;;
	800x480p60hz*)
		export X=800
		export Y=480
		;;
	800x600p60hz*)
		export X=800
		export Y=600
		;;
	1024x600p60hz*)
		export X=1024
		export Y=600
		;;
	1024x768p60hz*)
		export X=1024
		export Y=768
		;;
	1280x800p60hz*)
		export X=1280
		export Y=800
		;;
	1280x960p60hz*)
		export X=1280
		export Y=960
		;;
	1280x1024p60hz*)
		export X=1280
		export Y=1024
		;;
	1360x768p60hz*)
		export X=1360
		export Y=768
		;;
	1400x1050p60hz*)
		export X=1400
		export Y=1050
		;;
	1440x900p60hz*)
		export X=1440
		export Y=900
		;;
	1600x900p60hz*)
		export X=1600
		export Y=900
		;;
	1680x1050p60hz*)
		export X=1680
		export Y=1050
		;;
	1600x1200p60hz*)
		export X=1600
		export Y=1200
		;;
	1920x1200p60hz*)
		export X=1920
		export Y=1200
		;;
	2560x1080p60hz*)
		export X=2560
		export Y=1080
		;;
	2560x1440p60hz*)
		export X=2560
		export Y=1440
		;;
	2560x1600p60hz*)
		export X=2560
		export Y=1600
		;;
	3440x1440p60hz*)
		export X=3440
		export Y=1440
		;;
esac

common_display_setup

# Enable framebuffer device
echo 0 > /sys/class/graphics/fb0/blank

# Blank fb1 to prevent static noise
echo 1 > /sys/class/graphics/fb1/blank

echo 1 > /sys/devices/virtual/graphics/fbcon/cursor_blink

exit 0

################# manual ######################

# 480 Lines (720x480)
# "480i60hz" Interlaced 60Hz
# "480i_rpt" Interlaced for Rear Projection Televisions 60Hz
# "480p60hz" 480 Progressive 60Hz
# "480p_rpt" 480 Progressive for Rear Projection Televisions 60Hz

# 576 Lines (720x576)
# "576i50hz" Interlaced 50Hz
# "576i_rpt" Interlaced for Rear Projection Televisions 50Hz
# "576p50hz" Progressive 50Hz
# "576p_rpt" Progressive for Rear Projection Televisions 50Hz

# 720 Lines (1280x720)
# "720p50hz"  50Hz
# "720p60hz"  60Hz

# 1080 Lines (1920x1080)
# "1080i60hz" Interlaced 60Hz
# "1080p60hz" Progressive 60Hz
# "1080i50hz" Interlaced 50Hz
# "1080p50hz" Progressive 50Hz
# "1080p24hz" Progressive 24Hz

# 4K (3840x2160)
# "2160p30hz"    Progressive 30Hz
# "2160p25hz"    Progressive 25Hz
# "2160p24hz"    Progressive 24Hz
# "smpte24hz"    Progressive 24Hz SMPTE
# "2160p50hz"    Progressive 50Hz
# "2160p60hz"    Progressive 60Hz
# "2160p50hz420" Progressive 50Hz with YCbCr 4:2:0 (Requires TV/Monitor that supports it)
# "2160p60hz420" Progressive 60Hz with YCbCr 4:2:0 (Requires TV/Monitor that supports it)

### VESA modes ###
# "640x480p60hz"
# "800x480p60hz"
# "800x600p60hz"
# "1024x600p60hz"
# "1024x768p60hz"
# "1280x800p60hz"
# "1280x1024p60hz"
# "1360x768p60hz"
# "1440x900p60hz"
# "1600x900p60hz"
# "1680x1050p60hz"
# "1600x1200p60hz"
# "1920x1200p60hz"
# "2560x1080p60hz"
# "2560x1440p60hz"
# "2560x1600p60hz"
# "3440x1440p60hz"

# HDMI BPP Mode
# "32"
# "24"
# "16"
