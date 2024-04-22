#!/bin/bash

# Only for desktop
if [ "${XDG_SESSION_TYPE}" == "tty" ]; then
	exit
fi

WOL_NODE="/sys/class/wol/enable"

LIST_MENU=(Off On)
LIST_MENU_VALUE=(FALSE FALSE)

index=0

default_value=$(cat $WOL_NODE)

if [ $default_value -eq 0 ]; then
	index=0
else
	index=1
fi

DEFAULT_MODE=${LIST_MENU[$index]}
LIST_MENU_VALUE[$index]=TRUE

selected_mode=$(zenity --height=180 --width=300 \
	--list --radiolist \
	--title 'WOL Setting' \
	--text 'Select WOL Mode' \
	--window-icon /etc/fenix/icons/wol.png \
	--column 'Select' \
	--column 'Mode' \
	${LIST_MENU_VALUE[0]} ${LIST_MENU[0]} \
	${LIST_MENU_VALUE[1]} ${LIST_MENU[1]})

index=0
for i in ${LIST_MENU[@]}
do
	if [ "$selected_mode" == "$i" ]; then
		break
	fi
	index=$((index + 1))
done

selected_mode=${LIST_MENU[$index]}

if [ -z "$selected_mode" ] || [ "$selected_mode" == "$DEFAULT_MODE" ]; then
	exit
fi

# Change WOL mode
echo $index > $WOL_NODE

sync

exit
