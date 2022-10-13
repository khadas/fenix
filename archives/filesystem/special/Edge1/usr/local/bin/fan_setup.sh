#!/bin/bash

# Only for desktop
if ! which lightdm; then
	exit
fi

FAN="/usr/local/bin/fan.sh"

_fan_mode=$(${FAN} mode | grep "Fan mode:" | awk '{print $3}')
_fan_level=$(${FAN} mode | grep "Fan level:" | awk '{print $3}')
_fan_state=$(${FAN} mode | grep "Fan state:" | awk '{print $3}')

if [ "${_fan_state}" != "inactive" ]; then
	if [ "$_fan_mode" == "auto" ]; then
		fan_mode="auto"
	else
		fan_mode=${_fan_level}
	fi
else
	fan_mode="off"
fi

DEFAULT_FAN_MODE=${fan_mode}

LIST_MENU=(off low mid high auto)
LIST_MENU_VALUE=(FALSE FALSE FALSE FALSE FALSE)

index=0
for i in ${LIST_MENU[@]}
do
	if [ "$DEFAULT_FAN_MODE" == "$i" ]; then
		break
	fi
	index=$((index + 1))
done

LIST_MENU_VALUE[$index]=TRUE

selected_mode=$(zenity --height=250 --width=300 \
				--list --radiolist \
				--title 'FAN Setting' \
				--text 'Select FAN Mode' \
				--window-icon /etc/fenix/icons/fan.png \
				--column 'Select' \
				--column 'Mode' \
				${LIST_MENU_VALUE[0]} ${LIST_MENU[0]} \
				${LIST_MENU_VALUE[1]} ${LIST_MENU[1]} \
				${LIST_MENU_VALUE[2]} ${LIST_MENU[2]} \
				${LIST_MENU_VALUE[3]} ${LIST_MENU[3]} \
				${LIST_MENU_VALUE[4]} ${LIST_MENU[4]})

index=0
for i in ${LIST_MENU[@]}
do
	if [ "$selected_mode" == "$i" ]; then
		break
	fi
	index=$((index + 1))
done

selected_mode=${LIST_MENU[$index]}

if [ -z "$selected_mode" ] || [ "$selected_mode" == "$DEFAULT_FAN_MODE" ]; then
	exit
fi

# Change FAN mode
$FAN $selected_mode

zenity  --question \
	--text 'Do you want to save this mode to configuration file?' \
	--title 'Warning' \
	--window-icon /etc/fenix/icons/warning.png \
	--width=300 \
	--height=40 \
	--ok-label='Yes, save it' \
	--cancel-label="No, don't save"

if [ $? -ne 0 ]; then
	exit
fi

password=$(zenity --password --title 'Password')

sudo -k
if sudo -lS &> /dev/null << EOF
$password
EOF
then
	sudo sed -i "s/fan_mode=.*/fan_mode=$selected_mode/g" /boot/env.txt
fi

sync

exit
