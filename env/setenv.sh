#!/bin/bash

################################################################
ROOT="$(pwd)"

unset SUPPORTED_UBOOT
unset SUPPORTED_LINUX

DISTRIBUTION_ARRAY=("Ubuntu" "Debian")
Ubuntu_RELEASE_ARRAY=("bionic" "focal")
Debian_RELEASE_ARRAY=("buster")
DISTRIB_ARCH_ARRAY=("arm64" "armhf")
Ubuntu_TYPE_ARRAY=("server" "xfce" "lxde")
Debian_TYPE_ARRAY=("server" "xfce" "lxde")
INSTALL_TYPE_ARRAY=("EMMC" "SD-USB")

DISTRIBUTION_ARRAY_LEN=${#DISTRIBUTION_ARRAY[@]}
Ubuntu_RELEASE_ARRAY_LEN=${#Ubuntu_RELEASE_ARRAY[@]}
Debian_RELEASE_ARRAY_LEN=${#Debian_RELEASE_ARRAY[@]}
DISTRIB_ARCH_ARRAY_LEN=${#DISTRIB_ARCH_ARRAY[@]}
Ubuntu_TYPE_ARRAY_LEN=${#Ubuntu_TYPE_ARRAY[@]}
Debian_TYPE_ARRAY_LEN=${#Debian_TYPE_ARRAY[@]}
INSTALL_TYPE_ARRAY_LEN=${#INSTALL_TYPE_ARRAY[@]}

KHADAS_BOARD=
LINUX=
UBOOT=
DISTRIBUTION=
DISTRIB_RELEASE=
DISTRIB_ARCH=
INSTALL_TYPE=
DISTRIB_TYPE=
VENDOR=
CHIP=
EXPERT=

###############################################################
if [ "$1" == "expert" ]; then
	echo -e -n "\e[33mWarning:\e[0m You choose expert options mode, please make sure you know what you are doing. Switching to Expert mode? [N/y] "
	read result
	if [ "$result" == "y" -o "$result" == "Y" ]; then
		echo -e "\e[33mWarning:\e[0m Switching to Expert mode!"
		EXPERT="yes"
	else
		echo -e "\e[33mWarning:\e[0m Switching to Normal mode!"
		EXPERT=""
	fi
fi

## Hangup
hangup() {
	while true; do
		sleep 10
	done
}

## Export version
function export_version() {
	if [ ! -d "$ROOT/env" ]; then
		echo -e "\e[31mError:\e[0m You should execute the script in Fenix root directory by executing \e[0;32msource env/setenv.sh\e[0m.Please enter Fenix root directory and try again."
		echo -e "\e[0;32mCtrl+C\e[0m to abort."
		# Hang
		hangup
	fi

	source $ROOT/config/version
	export VERSION
}

## Choose Khadas board
function choose_khadas_board() {
	echo ""
	echo "Choose Khadas board:"
	i=0

	KHADAS_BOARD_ARRAY=()
	for board in $ROOT/config/boards/*.conf; do
		KHADAS_BOARD_ARRAY+=("$(basename $board | cut -d'.' -f1)")
	done

	KHADAS_BOARD_ARRAY_LEN=${#KHADAS_BOARD_ARRAY[@]}

	while [[ $i -lt $KHADAS_BOARD_ARRAY_LEN ]]
	do
		echo "$((${i}+1)). ${KHADAS_BOARD_ARRAY[$i]}"
		let i++
	done

	echo ""

	local DEFAULT_NUM
	DEFAULT_NUM=2

	export KHADAS_BOARD=
	local ANSWER
	while [ -z $KHADAS_BOARD ]
	do
		echo -n "Which board would you like? ["$DEFAULT_NUM"] "
		if [ -z "$1" ]; then
			read ANSWER
		else
			echo $1
			ANSWER=$1
		fi

		if [ -z "$ANSWER" ]; then
			ANSWER="$DEFAULT_NUM"
		fi

		if [ -n "`echo $ANSWER | sed -n '/^[0-9][0-9]*$/p'`" ]; then
			if [ $ANSWER -le $KHADAS_BOARD_ARRAY_LEN ] && [ $ANSWER -gt 0 ]; then
				index=$((${ANSWER}-1))
				KHADAS_BOARD="${KHADAS_BOARD_ARRAY[$index]}"
			else
				echo
				echo "number not in range. Please try again."
				echo
			fi
		else
			echo
			echo "I didn't understand your response.  Please try again."
			echo
		fi
		if [ -n "$1" ]; then
			break
		fi
	done

	source $ROOT/config/boards/${KHADAS_BOARD}.conf
}

## Choose uboot version
function choose_uboot_version() {
    echo ""
    echo "Choose uboot version:"
    i=0

    UBOOT_VERSION_ARRAY_LEN=${#SUPPORTED_UBOOT[@]}

	if [ $UBOOT_VERSION_ARRAY_LEN == 0 ]; then
		echo -e "\033[31mError:\033[0m Missing 'SUPPORTED_UBOOT' in board configuration file '$ROOT/config/boards/${KHADAS_BOARD}.conf'? Please add it!"
		echo -e "Hangup here! \e[0;32mCtrl+C\e[0m to abort."
		hangup
	fi

    while [[ $i -lt ${UBOOT_VERSION_ARRAY_LEN} ]]
    do
        echo "$((${i}+1)). uboot-${SUPPORTED_UBOOT[$i]}"
        let i++
    done

    echo ""

    local DEFAULT_NUM
    DEFAULT_NUM=1
    export UBOOT=
    local ANSWER
    while [ -z $UBOOT ]
    do
        echo -n "Which uboot version would you like? ["$DEFAULT_NUM"] "
        if [ -z "$1" ]; then
            read ANSWER
        else
            echo $1
            ANSWER=$1
        fi

        if [ -z "$ANSWER" ]; then
            ANSWER="$DEFAULT_NUM"
        fi

        if [ -n "`echo $ANSWER | sed -n '/^[0-9][0-9]*$/p'`" ]; then
            if [ $ANSWER -le ${UBOOT_VERSION_ARRAY_LEN} ] && [ $ANSWER -gt 0 ]; then
                index=$((${ANSWER}-1))
                UBOOT="${SUPPORTED_UBOOT[$index]}"
            else
                echo
                echo "number not in range. Please try again."
                echo
            fi
        else
            echo
            echo "I didn't understand your response.  Please try again."

            echo
        fi
        if [ -n "$1" ]; then
            break
        fi
    done
}

## Choose linux version
function choose_linux_version() {
	echo ""
	echo "Choose linux version:"
	# FIXME
	if [ "$UBOOT" == "mainline" ]; then
		SUPPORTED_LINUX=("mainline")
	else
		if [ "$EXPERT" != "yes" ]; then
			SUPPORTED_LINUX=(`echo ${SUPPORTED_LINUX[@]} | sed s/mainline//g`)
		fi
	fi

	i=0

	LINUX_VERSION_ARRAY_LEN=${#SUPPORTED_LINUX[@]}
	if [ $LINUX_VERSION_ARRAY_LEN == 0 ]; then
		echo -e "\033[31mError:\033[0m Missing 'SUPPORTED_LINUX' in board configuration file '$ROOT/config/boards/${KHADAS_BOARD}.conf'? Please add it!"
		echo -e "Hangup here! \e[0;32mCtrl+C\e[0m to abort."
		hangup
	fi

	while [[ $i -lt ${LINUX_VERSION_ARRAY_LEN} ]]
	do
		echo "$((${i}+1)). linux-${SUPPORTED_LINUX[$i]}"
		let i++
	done

	echo ""

	local DEFAULT_NUM
	DEFAULT_NUM=1

	export LINUX=
	local ANSWER
	while [ -z $LINUX ]
	do
		echo -n "Which linux version would you like? ["$DEFAULT_NUM"] "
		if [ -z "$1" ]; then
			read ANSWER
		else
			echo $1
			ANSWER=$1
		fi

		if [ -z "$ANSWER" ]; then
			ANSWER="$DEFAULT_NUM"
		fi

		if [ -n "`echo $ANSWER | sed -n '/^[0-9][0-9]*$/p'`" ]; then
			if [ $ANSWER -le ${LINUX_VERSION_ARRAY_LEN} ] && [ $ANSWER -gt 0 ]; then
				index=$((${ANSWER}-1))
				LINUX="${SUPPORTED_LINUX[$index]}"
			else
				echo
				echo "number not in range. Please try again."
				echo
			fi
		else
			echo
			echo "I didn't understand your response.  Please try again."

			echo
		fi
		if [ -n "$1" ]; then
			break
		fi
	done
}

## Choose distribution
function choose_distribution() {
	echo ""
	echo "Choose distribution:"
	i=0
	while [[ $i -lt $DISTRIBUTION_ARRAY_LEN ]]
	do
		echo "$((${i}+1)). ${DISTRIBUTION_ARRAY[$i]}"
		let i++
	done

	echo ""

	local DEFAULT_NUM
	DEFAULT_NUM=1

	export DISTRIBUTION
	local ANSWER
	while [ -z $DISTRIBUTION ]
	do
		echo -n "Which distribution would you like? ["$DEFAULT_NUM"] "
		if [ -z "$1" ]; then
			read ANSWER
		else
			echo $1
			ANSWER=$1
		fi

		if [ -z "$ANSWER" ]; then
			ANSWER="$DEFAULT_NUM"
		fi

		if [ -n "`echo $ANSWER | sed -n '/^[0-9][0-9]*$/p'`" ]; then
			if [ $ANSWER -le $DISTRIBUTION_ARRAY_LEN ] && [ $ANSWER -gt 0 ]; then
				index=$((${ANSWER}-1))
				DISTRIBUTION="${DISTRIBUTION_ARRAY[$index]}"
			else
				echo
				echo "number not in range. Please try again."
				echo
			fi
		else
			echo
			echo "I didn't understand your response.  Please try again."
			echo
		fi
		if [ -n "$1" ]; then
			break
		fi
	done
}

## Choose distribution release
function choose_distribution_release() {
	echo ""
	echo "Choose ${DISTRIBUTION} release:"

	i=0
	local DISTRIBUTION_RELEASE_ARRAY_LEN
	local DISTRIBUTION_RELEASE_ELEMENT
	local DISTRIBUTION_RELEASE

	DISTRIBUTION_RELEASE_ARRAY_LEN=${DISTRIBUTION}_RELEASE_ARRAY_LEN
	while [[ $i -lt ${!DISTRIBUTION_RELEASE_ARRAY_LEN} ]]
	do
		DISTRIBUTION_RELEASE_ARRAY_ELEMENT=${DISTRIBUTION}_RELEASE_ARRAY[$i]
		DISTRIBUTION_RELEASE=${!DISTRIBUTION_RELEASE_ARRAY_ELEMENT}
		echo "$((${i}+1)). ${DISTRIBUTION_RELEASE}"
		let i++
	done

	echo ""

	local DEFAULT_NUM
	DEFAULT_NUM=1

	export DISTRIB_RELEASE=
	local ANSWER
	while [ -z $DISTRIB_RELEASE ]
	do
		echo -n "Which ${DISTRIBUTION} release would you like? ["$DEFAULT_NUM"] "
		if [ -z "$1" ]; then
			read ANSWER
		else
			echo $1
			ANSWER=$1
		fi

		if [ -z "$ANSWER" ]; then
			ANSWER="$DEFAULT_NUM"
		fi

		if [ -n "`echo $ANSWER | sed -n '/^[0-9][0-9]*$/p'`" ]; then
			if [ $ANSWER -le ${!DISTRIBUTION_RELEASE_ARRAY_LEN} ] && [ $ANSWER -gt 0 ]; then
				index=$((${ANSWER}-1))
				DISTRIBUTION_RELEASE_ARRAY_ELEMENT=${DISTRIBUTION}_RELEASE_ARRAY[$index]
				DISTRIB_RELEASE="${!DISTRIBUTION_RELEASE_ARRAY_ELEMENT}"
			else
				echo
				echo "number not in range. Please try again."
				echo
			fi
		else
			echo
			echo "I didn't understand your response.  Please try again."

			echo
		fi
		if [ -n "$1" ]; then
			break
		fi
	done
}

## Choose distribution type
function choose_distribution_type() {
	echo ""
	echo "Choose ${DISTRIBUTION} type:"

	i=0
	local DISTRIBUTION_TYPE_ARRAY_LEN
	local DISTRIBUTION_TYPE_ELEMENT
	local DISTRIBUTION_TYPE

	DISTRIBUTION_TYPE_ARRAY_LEN=${DISTRIBUTION}_TYPE_ARRAY_LEN
	while [[ $i -lt ${!DISTRIBUTION_TYPE_ARRAY_LEN} ]]
	do
		DISTRIBUTION_TYPE_ARRAY_ELEMENT=${DISTRIBUTION}_TYPE_ARRAY[$i]
		DISTRIBUTION_TYPE=${!DISTRIBUTION_TYPE_ARRAY_ELEMENT}
		echo "$((${i}+1)). ${DISTRIBUTION_TYPE}"
		let i++
	done

	echo ""

	local DEFAULT_NUM
	DEFAULT_NUM=1

	export DISTRIB_TYPE=
	local ANSWER
	while [ -z $DISTRIB_TYPE ]
	do
		echo -n "Which ${DISTRIBUTION} type would you like? ["$DEFAULT_NUM"] "
		if [ -z "$1" ]; then
			read ANSWER
		else
			echo $1
			ANSWER=$1
		fi

		if [ -z "$ANSWER" ]; then
			ANSWER="$DEFAULT_NUM"
		fi

		if [ -n "`echo $ANSWER | sed -n '/^[0-9][0-9]*$/p'`" ]; then
			if [ $ANSWER -le ${!DISTRIBUTION_TYPE_ARRAY_LEN} ] && [ $ANSWER -gt 0 ]; then
				index=$((${ANSWER}-1))
				DISTRIBUTION_TYPE_ARRAY_ELEMENT=${DISTRIBUTION}_TYPE_ARRAY[$index]
				DISTRIB_TYPE="${!DISTRIBUTION_TYPE_ARRAY_ELEMENT}"
			else
				echo
				echo "number not in range. Please try again."
				echo
			fi
		else
			echo
			echo "I didn't understand your response.  Please try again."

			echo
		fi
		if [ -n "$1" ]; then
			break
		fi
	done
}

## Choose distribution arch
function choose_distribution_architecture() {

	if [ "$EXPERT" != "yes" ]; then
		echo ""
		echo "Set architecture to 'arm64' by default."
		DISTRIB_ARCH="arm64"
		export DISTRIB_ARCH
		return
	fi

	echo ""
	echo "Choose ${DISTRIBUTION} architecture:"
	i=0
	while [[ $i -lt $DISTRIB_ARCH_ARRAY_LEN ]]
	do
		echo "$((${i}+1)). ${DISTRIB_ARCH_ARRAY[$i]}"
		let i++
	done

	echo ""

	local DEFAULT_NUM
	DEFAULT_NUM=1

	export DISTRIB_ARCH=
	local ANSWER
	while [ -z $DISTRIB_ARCH ]
	do
		echo -n "Which ${DISTRIBUTION} architecture would you like? ["$DEFAULT_NUM"] "
		if [ -z "$1" ]; then
			read ANSWER
		else
			echo $1
			ANSWER=$1
		fi

		if [ -z "$ANSWER" ]; then
			ANSWER="$DEFAULT_NUM"
		fi

		if [ -n "`echo $ANSWER | sed -n '/^[0-9][0-9]*$/p'`" ]; then
			if [ $ANSWER -le $DISTRIB_ARCH_ARRAY_LEN ] && [ $ANSWER -gt 0 ]; then
				index=$((${ANSWER}-1))
				DISTRIB_ARCH="${DISTRIB_ARCH_ARRAY[$index]}"
			else
				echo
				echo "number not in range. Please try again."
				echo
			fi
		else
			echo
			echo "I didn't understand your response.  Please try again."
			echo
		fi

		if [ -n "$1" ]; then
			break
		fi
	done
}

function choose_install_type() {
	echo ""
	echo "Choose install type:"
	# FIXME
	if [ "$KHADAS_BOARD" != "Edge" ] && [ "$UBOOT" == "mainline" -o "$LINUX" == "mainline" ]; then
		INSTALL_TYPE_ARRAY=("SD-USB")
		INSTALL_TYPE_ARRAY_LEN=${#INSTALL_TYPE_ARRAY[@]}
	fi
	i=0
	while [[ $i -lt $INSTALL_TYPE_ARRAY_LEN ]]
	do
		echo "$((${i}+1)). ${INSTALL_TYPE_ARRAY[$i]}"
		let i++
	done

	echo ""

	local DEFAULT_NUM
	DEFAULT_NUM=1

	export INSTALL_TYPE=
	local ANSWER
	while [ -z $INSTALL_TYPE ]
	do
		echo -n "Which install type would you like? ["$DEFAULT_NUM"] "
		if [ -z "$1" ]; then
			read ANSWER
		else
			echo $1
			ANSWER=$1
		fi

		if [ -z "$ANSWER" ]; then
			ANSWER="$DEFAULT_NUM"
		fi

		if [ -n "`echo $ANSWER | sed -n '/^[0-9][0-9]*$/p'`" ]; then
			if [ $ANSWER -le $INSTALL_TYPE_ARRAY_LEN ] && [ $ANSWER -gt 0 ]; then
				index=$((${ANSWER}-1))
				INSTALL_TYPE="${INSTALL_TYPE_ARRAY[$index]}"
			else
				echo
				echo "number not in range. Please try again."
				echo
			fi
		else
			echo
			echo "I didn't understand your response.  Please try again."
			echo
		fi

		if [ -n "$1" ]; then
			break
		fi
	done
}

function lunch() {
	if [[ "$KHADAS_BOARD" =~ VIM[123] ]]; then
		export VENDOR="Amlogic"
		case "$KHADAS_BOARD" in
			VIM1)
				export CHIP="S905X"
				;;
			VIM2)
				export CHIP="S912"
				;;
			VIM3L)
				export CHIP="S905D3"
				;;
			VIM3)
				export CHIP="A311D"
				;;
		esac
	elif [[ "$KHADAS_BOARD" == "Edge" ]]; then
		export VENDOR="Rockchip"
		case "$KHADAS_BOARD" in
			Edge)
				export CHIP="RK3399"
				;;
		esac
	fi

	echo "==========================================="
	echo "#VERSION: $VERSION"
	echo
	echo "#KHADAS_BOARD=${KHADAS_BOARD}"
	echo "#VENDOR=${VENDOR}"
	echo "#CHIP=${CHIP}"
	echo "#LINUX=${LINUX}"
	echo "#UBOOT=${UBOOT}"
	echo "#DISTRIBUTION=${DISTRIBUTION}"
	echo "#DISTRIB_RELEASE=${DISTRIB_RELEASE}"
	echo "#DISTRIB_TYPE=${DISTRIB_TYPE}"
	echo "#DISTRIB_ARCH=${DISTRIB_ARCH}"
	echo "#INSTALL_TYPE=${INSTALL_TYPE}"
	echo
	echo "==========================================="
	echo ""
	echo "Environment setup done."
	echo "Type 'make' to build."
	echo ""
}

#####################################################################3
export_version
choose_khadas_board
choose_uboot_version
choose_linux_version
choose_distribution
choose_distribution_release
choose_distribution_type
choose_distribution_architecture
choose_install_type
lunch

export ARCH=arm64 
