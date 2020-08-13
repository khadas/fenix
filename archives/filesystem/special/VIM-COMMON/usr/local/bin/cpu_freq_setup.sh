#!/bin/bash

# Only for desktop
if ! which lightdm > /dev/null; then
    exit
fi

. /etc/fenix-release

if [ $BOARD == "VIM3L" ]; then
    FREQ_VALUE_Little=($(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq))
    LIST_MENU_Little=("500000" "667000" "1000000" "1200000" "1398000" "1512000" "1608000" "1704000" "1800000" "1908000-(Default)" "2016000-(Overclocking)" "2100000-(Overclocking)" "2208000-(Overclocking)")
	LIST_MENU_VALUES_Little=("500000" "667000" "1000000" "1200000" "1398000" "1512000" "1608000" "1704000" "1800000" "1908000" "2016000" "2100000" "2208000")
    num_little=${#LIST_MENU_Little[@]}
elif [ $BOARD == "VIM3" ]; then
    FREQ_VALUE_Little=($(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq))
    FREQ_VALUE_Big=($(cat /sys/devices/system/cpu/cpufreq/policy2/scaling_max_freq))
    LIST_MENU_Little=("500000" "667000" "1000000" "1200000" "1398000" "1512000" "1608000" "1704000" "1800000-(Default)" "1908000-(Overclocking)" "2016000-(Overclocking)" "2100000-(Overclocking)" "2208000-(Overclocking)")
    LIST_MENU_Big=("500000" "667000" "1000000" "1200000" "1398000" "1512000" "1608000" "1704000" "1800000" "1908000" "2016000" "2100000" "2208000-(Default)" "2304000-(Overclocking)" "2400000-(Overclocking)")
	LIST_MENU_VALUES_Little=("500000" "667000" "1000000" "1200000" "1398000" "1512000" "1608000" "1704000" "1800000" "1908000" "2016000" "2100000" "2208000")
	LIST_MENU_VALUES_Big=("500000" "667000" "1000000" "1200000" "1398000" "1512000" "1608000" "1704000" "1800000" "1908000" "2016000" "2100000" "2208000" "2304000" "2400000")
    num_little=${#LIST_MENU_Little[@]}
    num_big=${#LIST_MENU_Big[@]}
else
    exit
fi

m=0
while(( m<${num_little} ))
do
    temp=${LIST_MENU_VALUES_Little[m]}
    if [ ${temp} == ${FREQ_VALUE_Little} ]; then
        LIST_Little+="TRUE ${LIST_MENU_Little[m]} "
    else
        LIST_Little+="FALSE ${LIST_MENU_Little[m]} "
    fi
    let "m++"
done

if [ $BOARD == "VIM3" ]; then
    m=0
    while(( m<${num_big} ))
    do
		temp=${LIST_MENU_VALUES_Big[m]}
        if [ ${temp} == ${FREQ_VALUE_Big} ]; then
            LIST_Big+="TRUE ${LIST_MENU_Big[m]} "
        else
            LIST_Big+="FALSE ${LIST_MENU_Big[m]} "
        fi
        let "m++"
    done
fi

selected_Little_core=$(zenity --height=430 --width=280 \
        --list --radiolist \
        --title 'CPU Frequency Setting' \
        --text 'Select Little Core Freq' \
        --window-icon /etc/fenix/icons/CPU-frequency.svg \
        --column 'Select' \
        --column 'Freq (KHz)' \
        ${LIST_Little})

if [ $? -ne 0 ]; then
    exit
fi

index=0
for i in ${LIST_MENU_Little[@]}
do
	if [ "$selected_Little_core" == "$i" ]; then
		break
	fi
	index=$((index + 1))
done

selected_Little_core=${LIST_MENU_VALUES_Little[$index]}

if [ $BOARD == "VIM3" ]; then
    selected_Big_core=$(zenity --height=480 --width=280 \
            --list --radiolist \
            --title 'CPU Frequency Setting' \
            --text 'Select Big Core Freq' \
            --window-icon /etc/fenix/icons/CPU-frequency.svg \
            --column 'Select' \
            --column 'Freq (KHz)' \
            ${LIST_Big})

    if [ $? -ne 0 ]; then
        exit
    fi

	index=0
	for i in ${LIST_MENU_Big[@]}
	do
		if [ "$selected_Big_core" == "$i" ]; then
			break
		fi
		index=$((index + 1))
	done

	selected_Big_core=${LIST_MENU_VALUES_Big[$index]}
fi

if [[ ${BOARD} == "VIM3L" && ${selected_Little_core} == ${FREQ_VALUE_Little} ]]; then
    exit
elif [[ ${BOARD} == "VIM3" && ${selected_Big_core} == ${FREQ_VALUE_Big} && ${selected_Little_core} == ${FREQ_VALUE_Little} ]]; then
    exit
fi

password=$(zenity --password --title 'Password')

if [ $? -ne 0 ]; then
	exit
fi

if [ -z $password ]; then
	zenity --warning --height=100 --width=200 \
			--text="Password is empty!\n\nExit."
	exit
fi

sudo -k
if sudo -lS &> /dev/null << EOF
$password
EOF
then
    if [ $BOARD == "VIM3L" ]; then
        sudo sed -i "s/max_freq_a55=.*/max_freq_a55=${selected_Little_core:0:${#selected_Little_core}-3}/g" /boot/env.txt
    else
        sudo sed -i "s/max_freq_a53=.*/max_freq_a53=${selected_Little_core:0:${#selected_Little_core}-3}/g" /boot/env.txt
        sudo sed -i "s/max_freq_a73=.*/max_freq_a73=${selected_Big_core:0:${#selected_Big_core}-3}/g" /boot/env.txt
    fi
fi

sync

zenity --question --text 'Change the CPU Frequency need to reboot your system! \n\nDo you want to reboot now ?' \
           --title 'Warning' \
           --window-icon /etc/fenix/icons/warning.png \
           --width=350 \
           --height=50

if [ $? -ne 0 ]; then
    exit
fi

sudo reboot

exit
