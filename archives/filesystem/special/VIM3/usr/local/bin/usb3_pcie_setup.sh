#!/bin/bash

# Only for desktop
if ! which lightdm; then
	exit
fi

if linux-version compare `uname -r` ge 4.12; then
	IS_MAINLINE_KERNEL=yes
fi

USB3_PCIE_NODE="/sys/class/mcu/usb_pcie_switch_mode"
POWEROFF_NODE="/sys/class/mcu/poweroff"

LIST_MENU=(USB3.0 PCIe)
LIST_MENU_VALUE=(FALSE FALSE)

index=0

if [ "$IS_MAINLINE_KERNEL" != "yes" ]; then
	default_value=$(cat $USB3_PCIE_NODE)
else
	if [ `i2cget -f -y 0 0x18 0x33 b` == "0x00" ]; then
		default_value=0
	elif [ `i2cget -f -y 0 0x18 0x33 b` == "0x01" ]; then
		default_value=1
	else
		echo "Unknow value!"
		exit
	fi
fi

if [ $default_value -eq 0 ]; then
	index=0
else
	index=1
fi

DEFAULT_MODE=${LIST_MENU[$index]}
LIST_MENU_VALUE[$index]=TRUE

selected_mode=$(zenity --width=250 \
				--height=180 \
				--list --radiolist \
				--title 'USB3.0/PCIe Setting' \
				--text 'Select USB3.0/PCIe Mode' \
				--window-icon /etc/fenix/icons/usb3_pcie.png \
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

zenity  --question \
		--text 'You need to POWEOR OFF your device to make change available.\nDo you want to POWER OFF your device now?' \
		--title 'Warning' \
		--window-icon /etc/fenix/icons/warning.png \
		--width=480 \
		--height=50

if [ $? -ne 0 ]; then
	exit
fi

if [ "$IS_MAINLINE_KERNEL" != "yes" ]; then
	# Change USB3.0/PCIe mode
	echo $index > $USB3_PCIE_NODE
	sync
	# Poweroff
	echo 1 > $POWEROFF_NODE
else
	i2cset -f -y 0 0x18 0x33 $index b
	i2cset -f -y 0 0x18 0x80 1 b
fi

exit
