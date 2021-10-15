#!/bin/bash

# Default Configure

DEVICE="/dev/ttyS3"

BAUDRATE=115200

MENU_TEXT="Choose a control method\nDim for brightness"

MENU_RESULT=

DIM="e1"
RED="ff"
GREEN="ff"
BLUE="ff"

if [ -f "/tmp/Dim_templete_value" ]; then
	DIM=`cat /tmp/Dim_templete_value`
	if [ "X$DIM" == "Xe0" ];then
		DIM="e1"
	fi
fi

START_SIG="\x00\x00\x00\x00"
END_SIG="\xff\xff\xff\xff"


LOGO_DATA="\x00\x00\x00\x00\x$DIM\x00\xff\xff\x$DIM\x00\xff\xff\x$DIM\x00\xff\xff\x$DIM\x00\xff\x00\x$DIM\x00\xff\x00\x$DIM\xff\x00\x00\x$DIM\xff\x00\x00\x$DIM\xff\x00\x00\x$DIM\xff\x00\x00\x$DIM\xff\x00\x00\x$DIM\xff\x00\x00\x$DIM\xff\xff\xff\x$DIM\xff\xff\xff\x$DIM\xff\xff\xff\x$DIM\xff\xff\xff\x$DIM\xff\xff\xff\x$DIM\xff\xff\xff\x$DIM\xff\xff\xff\x$DIM\x00\x00\xff\x$DIM\x00\x00\xff\xff\xff\xff\xff"

# Setup Seriel

stty -F $DEVICE ispeed $BAUDRATE ospeed $BAUDRATE cs8


MENU_RESULT=`yad --width 400 --title "LED Control Menu" \
			--button "gtk-close:1" --button "gtk-ok:0" \
			--entry --entry-text "LOGO" "White" "Red" "Green" "Blue" "Manual" "Dim" "ColorTest" "Disable" \
			--text "$MENU_TEXT"`

if [ $? != 0 ]; then
	exit 0
fi

echo "aaaaaaaaaa"

if [ "X$MENU_RESULT" == "XManual" ]; then
	MANUAL_RESULT=`yad --width 500 --entry --text "Format/RGB:ffffff" \
				  --title "Set RGB Channel" --button="gtk-close:1" --button="gtk-ok:0"`
	if [ "X${#MANUAL_RESULT}" != "X6" ]; then
		yad --width 500 --text-align "center" --text "RGB channel format error !!!" --title "Set RGB Channel" \
			--button="gtk-close:1" --button="gtk-ok:0"
	fi
	RED=${MANUAL_RESULT:4:2}
	GREEN=${MANUAL_RESULT:2:2}
	BLUE=${MANUAL_RESULT:0:2}
else
	if [ "X$MENU_RESULT" == "XLOGO" ]; then
		echo "$LOGO_DATA" > /tmp/led_logo_data
		echo -e -n "$LOGO_DATA" > $DEVICE
		exit
	elif [ "X$MENU_RESULT" == "XRed" ]; then
		RED="ff"
		GREEN="00"
		BLUE="00"
	elif [ "X$MENU_RESULT" == "XGreen" ]; then
		RED="00"
		GREEN="ff"
		BLUE="00"
	elif [ "X$MENU_RESULT" == "XBlue" ]; then
		RED="00"
		GREEN="00"
		BLUE="ff"
	elif [ "X$MENU_RESULT" == "XDisable" ]; then
		DIM="e0"
	elif [ "X$MENU_RESULT" == "XDim" ]; then
		DIM_RESULT=`yad --width 500 --title "Choose the menu" \
				   --button="Set:0" --button="gtk-close:1" \
				   --scale --min-value=4 --max-value=34 --inc-buttons --hide-value`
		DIM_RESULT=$(($DIM_RESULT-3+224))
		DIM=`printf %x $DIM_RESULT`
		if [ -f "/tmp/led_logo_data" ]; then
			LOGO_DATA="\x00\x00\x00\x00\x$DIM\x00\xff\xff\x$DIM\x00\xff\xff\x$DIM\x00\xff\xff\x$DIM\x00\xff\x00\x$DIM\x00\xff\x00\x$DIM\xff\x00\x00\x$DIM\xff\x00\x00\x$DIM\xff\x00\x00\x$DIM\xff\x00\x00\x$DIM\xff\x00\x00\x$DIM\xff\x00\x00\x$DIM\xff\xff\xff\x$DIM\xff\xff\xff\x$DIM\xff\xff\xff\x$DIM\xff\xff\xff\x$DIM\xff\xff\xff\x$DIM\xff\xff\xff\x$DIM\xff\xff\xff\x$DIM\x00\x00\xff\x$DIM\x00\x00\xff\xff\xff\xff\xff"
			echo -e -n "$LOGO_DATA" > $DEVICE
			exit 0
		fi

	elif [ "X$MENU_RESULT" == "XColorTest" ]; then
		RED_10=255
		GREEN_10=0
		BLUE_10=0
		loop_data_blue=0
		loop_data_green=0
		while :
		do
			RED_16=`printf %02x $RED_10`
			while :
			do
				GREEN_16=`printf %02x $GREEN_10`
				while :
				do
					BLUE_16=`printf %02x $BLUE_10`
					LED_DATA="\x$DIM\x$RED_16\x$GREEN_16\x$BLUE_16"
					echo $LED_DATA
					FULL_LED_DATA=
					for i in $(seq 1 20)
					do
						FULL_LED_DATA+=$LED_DATA
					done
					FULL_SIG=$START_SIG$FULL_LED_DATA$END_SIG
					echo -e -n $FULL_SIG > $DEVICE
					sleep 0.1
					if [ $BLUE_10 == 255 ] && [ $loop_data_blue == 0 ]; then
						loop_data_blue=1
						break
					elif [ $BLUE_10 == 0 ] && [ $loop_data_blue == 1 ]; then
						loop_data_blue=0
						break
					fi
					if [ $loop_data_blue == 0 ];then
						BLUE_10=$(($BLUE_10+51))
					else
						BLUE_10=$(($BLUE_10-51))
					fi
				done
				if [ $GREEN_10 == 255 ] && [ $loop_data_green == 0 ]; then
					loop_data_green=1
					break
				elif [ $GREEN_10 == 0 ] && [ $loop_data_green == 1 ]; then
					loop_data_green=0
					break
				fi
				if [ $loop_data_green == 0 ];then
					GREEN_10=$(($GREEN_10+51))
				else
					GREEN_10=$(($GREEN_10-51))
				fi
			done
			if [ $RED_10 == 0 ]; then
				break
			fi
			RED_10=$(($RED_10-51))
		done
		exit 0
	fi
fi

rm -rf /tmp/led_logo_data

echo $DIM > /tmp/Dim_templete_value

LED_DATA="\x$DIM\x$RED\x$GREEN\x$BLUE"

for i in $(seq 1 20)
do
	FULL_LED_DATA+=$LED_DATA
done

FULL_SIG=$START_SIG$FULL_LED_DATA$END_SIG

echo -e -n $FULL_SIG > $DEVICE


