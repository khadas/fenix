#!/bin/bash

# Only for desktop
if [ "${XDG_SESSION_TYPE}" == "tty"]; then
	exit
fi

FAN="/usr/local/bin/fan.sh"

LINUX_VER=`uname -r`

if [ ${LINUX_VER::3} == "4.9" ] || [ ${LINUX_VER::3} == "5.4" ] || [ ${LINUX_VER::4} == "5.15" ];then
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
else
	fan_mode=$(${FAN} mode | grep "Fan mode:" | awk '{print $3}')
fi
DEFAULT_FAN_MODE=${fan_mode}

if [ ${LINUX_VER::3} == "4.9" ] || [ ${LINUX_VER::3} == "5.4" ] || [ ${LINUX_VER::4} == "5.15" ];then
	LIST_MENU=(off low mid high auto)
	LIST_MENU_VALUE=(FALSE FALSE FALSE FALSE FALSE)
else
	LIST_MENU=(manual auto)
	LIST_MENU_VALUE=(FALSE FALSE)
fi

if [ ${LINUX_VER::3} == "5.4" ] || [ ${LINUX_VER::4} == "5.15" ];then
	config_file='/boot/uEnv.txt'
else
	config_file='/boot/env.txt'
fi

index=0
for i in ${LIST_MENU[@]}
do
	if [ "$DEFAULT_FAN_MODE" == "$i" ]; then
		break
	fi
	index=$((index + 1))
done

LIST_MENU_VALUE[$index]=TRUE

if [ ${LINUX_VER::3} == "4.9" ] || [ ${LINUX_VER::3} == "5.4" ] || [ ${LINUX_VER::4} == "5.15" ];then
selected_mode=$(zenity --height=275 \
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
else
selected_mode=$(zenity --height=275 \
				--list --radiolist \
				--title 'FAN Setting' \
				--text 'Select FAN Mode' \
				--window-icon /etc/fenix/icons/fan.png \
				--column 'Select' \
				--column 'Mode' \
				${LIST_MENU_VALUE[0]} ${LIST_MENU[0]} \
				${LIST_MENU_VALUE[1]} ${LIST_MENU[1]})
fi

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

if [ $? -ne 0 ]; then
	exit
fi

if [ -z $password ]; then
	zenity --warning --height=100 --width=200 \
			--text="Password is empty!\nNothing saved!\n\nExit."

	exit
fi

sudo -k
if sudo -lS &> /dev/null << EOF
$password
EOF
then
	sudo sed -i "s/fan_mode=.*/fan_mode=$selected_mode/g" $config_file

fi

sync

exit
