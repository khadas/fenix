#!/bin/bash

################################################################

KHADAS_BOARD_ARRAY=("VIM" "VIM2")
VIM_SUPPORTED_LINUX_VERSION_ARRAY=("3.14" "4.9" "mainline")
VIM2_SUPPORTED_LINUX_VERSION_ARRAY=("3.14" "4.9")
VIM_SUPPORTED_UBOOT_VERSION_ARRAY=("2015.01" "mainline")
VIM2_SUPPORTED_UBOOT_VERSION_ARRAY=("2015.01")
UBUNTU_VERSION_ARRAY=("16.04.2" "17.04" "17.10")
UBUNTU_ARCH_ARRAY=("arm64" "armhf")
INSTALL_TYPE_ARRAY=("EMMC" "SD-USB")
UBUNTU_TYPE_ARRAY=("server" "mate")
UBUNTU_MATE_ROOTFS_TYPE_ARRAY=("chroot-install" "mate-rootfs")

KHADAS_BOARD_ARRAY_LEN=${#KHADAS_BOARD_ARRAY[@]}
VIM_SUPPORTED_LINUX_VERSION_ARRAY_LEN=${#VIM_SUPPORTED_LINUX_VERSION_ARRAY[@]}
VIM2_SUPPORTED_LINUX_VERSION_ARRAY_LEN=${#VIM2_SUPPORTED_LINUX_VERSION_ARRAY[@]}
VIM_SUPPORTED_UBOOT_VERSION_ARRAY_LEN=${#VIM_SUPPORTED_UBOOT_VERSION_ARRAY[@]}
VIM2_SUPPORTED_UBOOT_VERSION_ARRAY_LEN=${#VIM2_SUPPORTED_UBOOT_VERSION_ARRAY[@]}
UBUNTU_VERSION_ARRAY_LEN=${#UBUNTU_VERSION_ARRAY[@]}
UBUNTU_ARCH_ARRAY_LEN=${#UBUNTU_ARCH_ARRAY[@]}
INSTALL_TYPE_ARRAY_LEN=${#INSTALL_TYPE_ARRAY[@]}
UBUNTU_TYPE_ARRAY_LEN=${#UBUNTU_TYPE_ARRAY[@]}
UBUNTU_MATE_ROOTFS_TYPE_ARRAY_LEN=${#UBUNTU_MATE_ROOTFS_TYPE_ARRAY[@]}

KHADAS_BOARD=
LINUX=
UBOOT=
UBUNTU=
UBUNTU_ARCH=
INSTALL_TYPE=
UBUNTU_TYPE=
UBUNTU_MATE_ROOTFS_TYPE=

###############################################################
## Choose Khadas board
function choose_khadas_board() {
	echo ""
	echo "Choose Khadas board:"
	i=0
	while [[ $i -lt $KHADAS_BOARD_ARRAY_LEN ]]
	do
		echo "$((${i}+1)). ${KHADAS_BOARD_ARRAY[$i]}"
		let i++
	done

	echo ""

	local DEFAULT_NUM
	DEFAULT_NUM=1

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
}

## Choose linux version
function choose_linux_version() {
	echo ""
	echo "Choose linux version:"
	# FIXME
	if [ "$UBOOT" == "mainline" ]; then
		echo "Force set to linux-mainline"
		export LINUX="mainline"
		return 0
	fi

	i=0
	local LINUX_VERSION_ARRAY_LEN
	local LINUX_VERSION_ARRAY_ELEMENT
	local LINUX_VERSION

	LINUX_VERSION_ARRAY_LEN=${KHADAS_BOARD}_SUPPORTED_LINUX_VERSION_ARRAY_LEN
	while [[ $i -lt ${!LINUX_VERSION_ARRAY_LEN} ]]
	do
		LINUX_VERSION_ARRAY_ELEMENT=${KHADAS_BOARD}_SUPPORTED_LINUX_VERSION_ARRAY[$i]
		LINUX_VERSION=${!LINUX_VERSION_ARRAY_ELEMENT}
		echo "$((${i}+1)). linux-${LINUX_VERSION}"
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
			if [ $ANSWER -le ${!LINUX_VERSION_ARRAY_LEN} ] && [ $ANSWER -gt 0 ]; then
				index=$((${ANSWER}-1))
				LINUX_VERSION_ARRAY_ELEMENT=${KHADAS_BOARD}_SUPPORTED_LINUX_VERSION_ARRAY[$index]
				LINUX="${!LINUX_VERSION_ARRAY_ELEMENT}"
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

## Choose uboot version
function choose_uboot_version() {
    echo ""
    echo "Choose uboot version:"
    i=0
    local UBOOT_VERSION_ARRAY_LEN
    local UBOOT_VERSION_ARRAY_ELEMENT
    local UBOOT_VERSION

    UBOOT_VERSION_ARRAY_LEN=${KHADAS_BOARD}_SUPPORTED_UBOOT_VERSION_ARRAY_LEN
    while [[ $i -lt ${!UBOOT_VERSION_ARRAY_LEN} ]]
    do
        UBOOT_VERSION_ARRAY_ELEMENT=${KHADAS_BOARD}_SUPPORTED_UBOOT_VERSION_ARRAY[$i]
        UBOOT_VERSION=${!UBOOT_VERSION_ARRAY_ELEMENT}
        echo "$((${i}+1)). uboot-${UBOOT_VERSION}"
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
            if [ $ANSWER -le ${!UBOOT_VERSION_ARRAY_LEN} ] && [ $ANSWER -gt 0 ]; then
                index=$((${ANSWER}-1))
                UBOOT_VERSION_ARRAY_ELEMENT=${KHADAS_BOARD}_SUPPORTED_UBOOT_VERSION_ARRAY[$index]
                UBOOT="${!UBOOT_VERSION_ARRAY_ELEMENT}"
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


## Choose ubuntu version
function choose_ubuntu_version() {
	echo ""
	echo "Choose ubuntu version:"
	i=0
	while [[ $i -lt $UBUNTU_VERSION_ARRAY_LEN ]]
	do
		echo "$((${i}+1)). ubuntu-${UBUNTU_VERSION_ARRAY[$i]}"
		let i++
	done

	echo ""

	local DEFAULT_NUM
	DEFAULT_NUM=1

	export UBUNTU=
	local ANSWER
	while [ -z $UBUNTU ]
	do
		echo -n "Which ubuntu version would you like? ["$DEFAULT_NUM"] "
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
			if [ $ANSWER -le $UBUNTU_VERSION_ARRAY_LEN ] && [ $ANSWER -gt 0 ]; then
				index=$((${ANSWER}-1))
				UBUNTU="${UBUNTU_VERSION_ARRAY[$index]}"
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

## Choose ubuntu arch
function choose_ubuntu_architecture() {
	echo ""
	echo "Choose ubuntu architecture:"
	i=0
	while [[ $i -lt $UBUNTU_ARCH_ARRAY_LEN ]]
	do
		echo "$((${i}+1)). ubuntu-${UBUNTU_ARCH_ARRAY[$i]}"
		let i++
	done

	echo ""

	local DEFAULT_NUM
	DEFAULT_NUM=1

	export UBUNTU_ARCH=
	local ANSWER
	while [ -z $UBUNTU_ARCH ]
	do
		echo -n "Which ubuntu architecture would you like? ["$DEFAULT_NUM"] "
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
			if [ $ANSWER -le $UBUNTU_ARCH_ARRAY_LEN ] && [ $ANSWER -gt 0 ]; then
				index=$((${ANSWER}-1))
				UBUNTU_ARCH="${UBUNTU_ARCH_ARRAY[$index]}"
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
	if [ "$UBOOT" == "mainline" ]; then
		echo "Force set to install-${INSTALL_TYPE_ARRAY[1]}"
		export INSTALL_TYPE="${INSTALL_TYPE_ARRAY[1]}"
		return
	else
		i=0
		while [[ $i -lt $INSTALL_TYPE_ARRAY_LEN ]]
		do
			echo "$((${i}+1)). install-${INSTALL_TYPE_ARRAY[$i]}"
			let i++
		done
	fi

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

function choose_ubuntu_type() {
	echo ""
	echo "Choose ubuntu type:"
	i=0
	while [[ $i -lt $UBUNTU_TYPE_ARRAY_LEN ]]
	do
		echo "$((${i}+1)). ubuntu-${UBUNTU_TYPE_ARRAY[$i]}"
		let i++
	done

	echo ""

	local DEFAULT_NUM
	DEFAULT_NUM=1

	export UBUNTU_TYPE=
	local ANSWER
	while [ -z $UBUNTU_TYPE ]
	do
		echo -n "Which ubuntu type would you like? ["$DEFAULT_NUM"] "
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
			if [ $ANSWER -le $UBUNTU_TYPE_ARRAY_LEN ] && [ $ANSWER -gt 0 ]; then
				index=$((${ANSWER}-1))
				UBUNTU_TYPE="${UBUNTU_TYPE_ARRAY[$index]}"
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

function choose_ubuntu_mate_rootfs_type() {
	if [ "$UBUNTU_TYPE" != "mate" ]; then
		return
	fi

	echo ""
	echo "Choose ubuntu mate rootfs type:"
	i=0
	while [[ $i -lt $UBUNTU_MATE_ROOTFS_TYPE_ARRAY_LEN ]]
	do
		echo "$((${i}+1)). ${UBUNTU_MATE_ROOTFS_TYPE_ARRAY[$i]}"
		let i++
	done

	echo ""

	local DEFAULT_NUM
	DEFAULT_NUM=1

	export UBUNTU_MATE_ROOTFS_TYPE=
	local ANSWER
	while [ -z $UBUNTU_MATE_ROOTFS_TYPE ]
	do
		echo -n "Which ubuntu mate rootfs type would you like? ["$DEFAULT_NUM"] "
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
			if [ $ANSWER -le $UBUNTU_MATE_ROOTFS_TYPE_ARRAY_LEN ] && [ $ANSWER -gt 0 ]; then
				index=$((${ANSWER}-1))
				UBUNTU_MATE_ROOTFS_TYPE="${UBUNTU_MATE_ROOTFS_TYPE_ARRAY[$index]}"
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
	echo "==========================================="
	echo
	echo "#KHADAS_BOARD=${KHADAS_BOARD}"
	echo "#LINUX=${LINUX}"
	echo "#UBOOT=${UBOOT}"
	echo "#UBUNTU_TYPE=${UBUNTU_TYPE}"
	if [ "$UBUNTU_TYPE" == "mate" ]; then
		echo "#UBUNTU_MATE_ROOTFS_TYPE=${UBUNTU_MATE_ROOTFS_TYPE}"
	fi
	echo "#UBUNTU=${UBUNTU}"
	echo "#UBUNTU_ARCH=${UBUNTU_ARCH}"
	echo "#INSTALL_TYPE=${INSTALL_TYPE}"
	echo
	echo "==========================================="
}

#####################################################################3
choose_khadas_board
choose_uboot_version
choose_linux_version
choose_ubuntu_version
choose_ubuntu_architecture
choose_ubuntu_type
choose_ubuntu_mate_rootfs_type
choose_install_type
lunch

