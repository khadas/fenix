#!/bin/bash

# Fenix build env configurator

SRC=$(realpath "${BASH_SOURCE:-$0}"); ROOT=${SRC%/*}/..; CDIR=$PWD

CONFIG_ARGS="KHADAS_BOARD LINUX UBOOT DISTRIBUTION DISTRIB_RELEASE
	     DISTRIB_TYPE DISTRIB_ARCH INSTALL_TYPE "
CONFIG_ADDS="COMPRESS_IMAGE INSTALL_TYPE_RAW"

USAGE(){ echo "\
USAGE: source setenv.sh [ PARAM=VAL | CONFIG_FILE ]* [-h|-d|-s|-q|-qq|-1|-z]

        -h|--help          - this usage/help    || -1 - short-read mode
        -d|--default       - fill by default values if not defined
        -s|--noask         - no ask non interractive error mode
        -q|--quit          - quit mode | -qq - more quit mode only errors
        -z|--clean         - clean up fenix env
        PARAM=VAL          - param value pair
        CONFIG_FILE        - read config/template file
	config CONFIG_FILE - equal 'CONFIG_FILE --noask --quit'
	-c|--config        - same as 'config CONFIG_FILE'

NOTES + run without param start default interractive mode
      + parameters redefined by order presented in command line and config files
      + --default or --noask - usage generate error exit code if configuration
        was not resolved correctly - usefull for non interactive script usage
      + source fenix/setenv.sh -d && make -C fenix # can used from any location

PARAMS:
    $(echo $CONFIG_ARGS)

ADDITIONAL PARAMS:
    $(echo $CONFIG_ADDS)

EXAMPLES:
    source setenv.sh                                    # interractive mode
    source setenv.sh KHADAS_BOARD=VIM2                  # interractive mode for VIM2
    source setenv.sh KHADAS_BOARD=VIM2 --default	# non interractive mode
    source setenv.sh KHADAS_BOARD=VIM3L -d && echo OK           # same for scripting usage
    source setenv.sh KHADAS_BOARD=wrong_board -d || echo ERROR  #
    source setenv.sh KHADAS_BOARD=VIM3L -s || echo ERROR SOME_PARAM UNDEFINED
    source setenv.sh KHADAS_BOARD=VIM3L LINUX=wrong_version -d || echo ERROR WRONG PARAM VALUE
    source setenv.sh KHADAS_BOARD=VIM3L LINUX=mainline COMPRESS_IMAGE=yes -d # generate next
    source setenv.sh KHADAS_BOARD=VIM3L LINUX=mainline UBOOT=mainline \\
                     DISTRIBUTION=Ubuntu DISTRIB_RELEASE=bionic DISTRIB_TYPE=server \\
                     DISTRIB_ARCH=arm64 INSTALL_TYPE=SD-USB COMPRESS_IMAGE=yes -s
    source setenv.sh config config-template.conf	# config file usage
    source setenv.sh your-config-template.conf
"
}

USAGE_HELP(){ echo "\
[i] GET USAGE INFO: source setenv.sh --help"
	return $1
}

[ ! "$BASH_SOURCE" ] && {
	echo "[e] bash required" && USAGE_HELP && return 1
	exit 1 # fail safe exit
}

DIE(){
	echo "[e] $@">&2
	[ "$BASH_SOURCE" = $0 ] && exit 1
	return 1
}

RETURN(){
	[ "$BASH_SOURCE" = $0 ] && exit $1
	return $1
}

################################################################

# parse ARGS as PARAMS

unset_vars(){
    local t
    for t in $@; do
	unset $t
	export $t
    done
}

LOCAL="REUSE AUTOFILL LOAD_CONFIG_FROM_FILE
    NOASK QUITMODE CONFIG_FILE SHORT_READ"


unset_local(){
    unset_vars $LOCAL CONFIG_ARGS CONFIG_ADDS LOCAL CDIR SCRIPT
}

unset_vars VENDOR CHIP $LOCAL

for a in "$@"; do
    case $a in
    -r|--reuse)
    REUSE=1
    ;;
    -z|--clean)
    echo "[i] clean up fenix env"
    unset_vars $CONFIG_ARGS $CONFIG_ADDS VERSION CHIP VENDOR
    unset_local
    RETURN || return
    ;;
    -h|--help)
    USAGE
    RETURN || return
    ;;
    -q|--quit)
    QUITMODE=$((QUITMODE+1))
    ;;
    -qq)
    QUITMODE=2
    ;;
esac
done

[ "$REUSE" ] || unset_vars $CONFIG_ARGS $CONFIG_ADDS

echo_(){
	[ "$QUITMODE" ] || echo "$@"
}

for a in "$@"; do
    case $a in
    -d|--default)
    AUTOFILL=1
    ;;
    -1|--short-read)
    SHORT_READ=-n1
    ;;
    -q|--quit|-qq)
    ;;
    -s|--noask)
    NOASK=1
    ;;
    -c|--config|config)
    LOAD_CONFIG_FROM_FILE=1
    NOASK=1
    QUITMODE=1
    ;;
    *=*)
    #echo "[i] args export $a">&2
    #[ "CHECK_ARGS" ] && \
    for t in $CONFIG_ARGS $CONFIG_ADDS OOOPS; do
	[ "$t" = "${a%%=*}" ] && break
	[ ! "$t" = OOOPS ] || USAGE_HELP 1 || \
		DIE "unrecognized param: ${a%%=*}" || return
    done

    export $a
    ;;
    *)
    [ "$LOAD_CONFIG_FROM_FILE" ] && \
	CONFIG_FILE="$a"
    [ -s "$a" ] && \
	CONFIG_FILE="$a"

    [ "$CONFIG_FILE" ] && {
	[ -e "$CONFIG_FILE" ] || {
	    DIE "$CONFIG_FILE not found"
	    return 1
	}
	echo_ "[i] read config $CONFIG_FILE">&2
	source $CONFIG_FILE
	CONFIG_FILE=
	continue
    }

    DIE "unrecognized param $a" || USAGE_HELP

    RETURN 1 || return
    ;;
    esac
done
unset a t

[ "$BASH_SOURCE" = $0 ] && \
	echo "[e] standalone usage not allowed! only as sourced script!" && \
	USAGE_HELP && exit 1

[ "$NOASK" -o "$AUTOFILL" ] || [ ! "$QUITMODE" ] || \
	DIE "quit mode must used with no-ask or default mode" || return 1

## prepare

unset_vars VENDOR CHIP

unset SUPPORTED_UBOOT
unset SUPPORTED_LINUX
unset SUPPORTED_UBOOT_DESC
unset SUPPORTED_LINUX_DESC

DISTRIBUTION_ARRAY=("Ubuntu" "Debian")
DISTRIBUTION_ARRAY_DESC=("Ubuntu" "Debian")
Ubuntu_RELEASE_ARRAY=("bionic" "focal")
Ubuntu_RELEASE_ARRAY_DESC=("Ubuntu 18.04" "Ubuntu 20.04")
Debian_RELEASE_ARRAY=("buster")
Debian_RELEASE_ARRAY_DESC=("Debian 10")
DISTRIB_ARCH_ARRAY=("arm64")
Ubuntu_TYPE_ARRAY=("server" "minimal" "xfce" "lxde" "gnome")
Ubuntu_TYPE_ARRAY_DESC=("Headless Image With Essential Packages"\
						"Minimal Image With Very Basic Packages"\
						"Desktop Image With XFCE Desktop"\
						"Desktop Image With LXDE Desktop"\
						"Desktop Image With GNOME Desktop")
Debian_TYPE_ARRAY=("server" "minimal" "xfce" "lxde")
Debian_TYPE_ARRAY_DESC=("Headless Image With Essential Packages"\
						"Minimal Image With Very Basic Packages"\
						"Desktop Image With XFCE Desktop"\
						"Desktop Image With LXDE Desktop")
INSTALL_TYPE_ARRAY=("EMMC" "SD-USB")
INSTALL_TYPE_ARRAY_DESC=("Image For Writing to eMMC Storage With USB Burning Tool"\
						 "Image For Writing to SD/USB Storage")

DISTRIBUTION_ARRAY_LEN=${#DISTRIBUTION_ARRAY[@]}
Ubuntu_RELEASE_ARRAY_LEN=${#Ubuntu_RELEASE_ARRAY[@]}
Debian_RELEASE_ARRAY_LEN=${#Debian_RELEASE_ARRAY[@]}
DISTRIB_ARCH_ARRAY_LEN=${#DISTRIB_ARCH_ARRAY[@]}
Ubuntu_TYPE_ARRAY_LEN=${#Ubuntu_TYPE_ARRAY[@]}
Debian_TYPE_ARRAY_LEN=${#Debian_TYPE_ARRAY[@]}
INSTALL_TYPE_ARRAY_LEN=${#INSTALL_TYPE_ARRAY[@]}



echo2(){
	[ "$QUITMODE" = 2 ] || echo "$@"
}

noask(){
	[ "$NOASK" ] || return 1
	echo2 "[i] NOASK mode"
}

wrong_num(){
	echo_ "\
number not in range. Please try again.
"
}

wrong_res(){
	echo_ "\
I didn't understand your response.  Please try again.
"
}

## Export version
function export_version() {
	VERSION=
	source $ROOT/config/version
	[ "$VERSION" ] || return 1
	export VERSION
}

## Choose Khadas board
function choose_khadas_board() {

	echo_ ""
	echo_ "Choose Khadas board:"
	i=0

	KHADAS_BOARD_ARRAY=()
	for board in $ROOT/config/boards/*.conf; do
		if [ $(basename $board) != "Generic.conf" ]; then
			KHADAS_BOARD_ARRAY+=("$(basename $board | cut -d'.' -f1)")
		fi
	done
	# Append Generic configuration to last
	if [ -f $ROOT/config/boards/Generic.conf ]; then
		KHADAS_BOARD_ARRAY+=("Generic")
	fi

	KHADAS_BOARD_ARRAY_LEN=${#KHADAS_BOARD_ARRAY[@]}

	while [[ $i -lt $KHADAS_BOARD_ARRAY_LEN ]]
	do
		BOARD_DESC=`head -1 $ROOT/config/boards/${KHADAS_BOARD_ARRAY[$i]}.conf`
		BOARD_DESC=${BOARD_DESC:2}
		echo_ "$((${i}+1)). ${KHADAS_BOARD_ARRAY[$i]} - ${BOARD_DESC}"
		[ "${KHADAS_BOARD_ARRAY[$i]}" = "$KHADAS_BOARD" ] && return 0
		let i++
	done

	[ "$NOASK" -o "$AUTOFILL" ] || KHADAS_BOARD=
	[ "$KHADAS_BOARD" ] && return 1

	echo_ ""

	local DEFAULT_NUM
	DEFAULT_NUM=2

	export KHADAS_BOARD=
	local ANSWER
	while [ -z $KHADAS_BOARD ]
	do
		[ "$AUTOFILL" ] || \
		if [ -z "$1" ]; then
			noask && return 1
			echo_ -n "Which board would you like? ["$DEFAULT_NUM"] "
			read $SHORT_READ ANSWER
			[ "$SHORT_READ" ] && echo_
		else
			echo_ $1
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
				wrong_num
			fi
		else
		    wrong_res
		fi

		if [ -n "$1" ]; then
			break
		fi
	done
}

## Choose uboot version
function choose_uboot_version() {
    echo_
    echo_ "Choose uboot version:"
    i=0

    UBOOT_VERSION_ARRAY_LEN=${#SUPPORTED_UBOOT[@]}

	if [ $UBOOT_VERSION_ARRAY_LEN == 0 ]; then
		DIE "Missing 'SUPPORTED_UBOOT' in board configuration
file '$ROOT/config/boards/${KHADAS_BOARD}.conf'? Please add it!"
		return 1
	fi

    while [[ $i -lt ${UBOOT_VERSION_ARRAY_LEN} ]]
    do
        echo_ "$((${i}+1)). uboot-${SUPPORTED_UBOOT[$i]} - ${SUPPORTED_UBOOT_DESC[$i]}"
	[ "${SUPPORTED_UBOOT[$i]}" = "$UBOOT" ] && return 0
        let i++
    done

    [ "$NOASK" -o "$AUTOFILL" ] || UBOOT=
    [ "$UBOOT" ] && return 1

    echo_

    local DEFAULT_NUM
    DEFAULT_NUM=1
    export UBOOT=
    local ANSWER
    while [ -z $UBOOT ]
    do
	[ "$AUTOFILL" ] || \
        if [ -z "$1" ]; then
	    noask && return 1
	    echo_ -n "Which uboot version would you like? ["$DEFAULT_NUM"] "
            read $SHORT_READ ANSWER
	    [ "$SHORT_READ" ] && echo_

        else
            echo_ $1
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
                wrong_num
            fi
        else
            wrong_res
        fi

        if [ -n "$1" ]; then
            break
        fi
    done
}

## Choose linux version
function choose_linux_version() {
	echo_
	echo_ "Choose linux version:"
	# FIXME
	if [ "$UBOOT" == "mainline" ]; then
		SUPPORTED_LINUX=("mainline")
	else
		if [ "$KHADAS_BOARD" != "Generic" ]; then
			SUPPORTED_LINUX=(`echo ${SUPPORTED_LINUX[@]} | sed s/mainline//g`)
		fi
	fi

	i=0

	LINUX_VERSION_ARRAY_LEN=${#SUPPORTED_LINUX[@]}
	if [ $LINUX_VERSION_ARRAY_LEN == 0 ]; then
		DIE "Missing 'SUPPORTED_LINUX' in board configuration
file '$ROOT/config/boards/${KHADAS_BOARD}.conf'? Please add it!"
		return 1
	fi

	while [[ $i -lt ${LINUX_VERSION_ARRAY_LEN} ]]
	do
		echo_ "$((${i}+1)). linux-${SUPPORTED_LINUX[$i]}"
		[ "${SUPPORTED_LINUX[$i]}" = "$LINUX" ] && return 0
		let i++
	done
	
	[ "$NOASK" -o "$AUTOFILL" ] || LINUX=
	[ "$LINUX" ] && return 1

	echo_

	# no need ask if only one choose ;-)
	[ "$LINUX_VERSION_ARRAY_LEN" = 1 ] && echo_ -n "only one choose " && \
		LINUX=$SUPPORTED_LINUX && return 0

	local DEFAULT_NUM
	DEFAULT_NUM=1

	export LINUX=
	local ANSWER
	while [ -z $LINUX ]
	do
		[ "$AUTOFILL" ] || \
		if [ -z "$1" ]; then
			noask && return 1
			echo_ -n "Which linux version would you like? ["$DEFAULT_NUM"] "
			read $SHORT_READ ANSWER
			[ "$SHORT_READ" ] && echo_
		else
			echo_ $1
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
				wrong_num
			fi
		else
			wrong_res
		fi

		if [ -n "$1" ]; then
			break
		fi
	done
}

## Choose distribution
function choose_distribution() {
	echo_
	echo_ "Choose distribution:"
	i=0
	while [[ $i -lt $DISTRIBUTION_ARRAY_LEN ]]
	do
		echo_ "$((${i}+1)). ${DISTRIBUTION_ARRAY[$i]} - ${DISTRIBUTION_ARRAY_DESC[$i]}"
		[ "${DISTRIBUTION_ARRAY[$i]}" = "$DISTRIBUTION" ] && return 0
		let i++
	done


	[ "$NOASK" -o "$AUTOFILL" ] || DISTRIBUTION=
	[ "$DISTRIBUTION" ] && return 1

	echo_

	local DEFAULT_NUM
	DEFAULT_NUM=1

	export DISTRIBUTION=
	local ANSWER
	while [ -z $DISTRIBUTION ]
	do
		[ "$AUTOFILL" ] || \
		if [ -z "$1" ]; then
			noask && return 1
			echo_ -n "Which distribution would you like? ["$DEFAULT_NUM"] "
			read $SHORT_READ ANSWER
			[ "$SHORT_READ" ] && echo_
		else
			echo_ $1
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
				wrong_num
			fi
		else
			wrong_res
		fi

		if [ -n "$1" ]; then
			break
		fi
	done
}

## Choose distribution release
function choose_distribution_release() {
	echo_
	echo_ "Choose ${DISTRIBUTION} release:"

	i=0
	local DISTRIBUTION_RELEASE_ARRAY_LEN
	local DISTRIBUTION_RELEASE_ELEMENT
	local DISTRIBUTION_RELEASE

	DISTRIBUTION_RELEASE_ARRAY_LEN=${DISTRIBUTION}_RELEASE_ARRAY_LEN
	while [[ $i -lt ${!DISTRIBUTION_RELEASE_ARRAY_LEN} ]]
	do
		DISTRIBUTION_RELEASE_ARRAY_ELEMENT=${DISTRIBUTION}_RELEASE_ARRAY[$i]
		DISTRIBUTION_RELEASE_ARRAY_ELEMENT_DESC=${DISTRIBUTION}_RELEASE_ARRAY_DESC[$i]
		DISTRIBUTION_RELEASE=${!DISTRIBUTION_RELEASE_ARRAY_ELEMENT}
		DISTRIBUTION_RELEASE_DESC=${!DISTRIBUTION_RELEASE_ARRAY_ELEMENT_DESC}
		echo_ "$((${i}+1)). ${DISTRIBUTION_RELEASE} - ${DISTRIBUTION_RELEASE_DESC}"
		[ "$DISTRIBUTION_RELEASE" = "$DISTRIB_RELEASE" ] && return 0
		let i++
	done

	[ "$NOASK" -o "$AUTOFILL" ] || DISTRIB_RELEASE=
	[ "$DISTRIB_RELEASE" ] && return 1

	echo_

	# no need ask if only one choose ;-)
	[ ${!DISTRIBUTION_RELEASE_ARRAY_LEN} = 1 ] && echo_ -n "only one choose " && \
		DISTRIB_RELEASE=$DISTRIBUTION_RELEASE && return 0

	local DEFAULT_NUM
	DEFAULT_NUM=2

	export DISTRIB_RELEASE=
	local ANSWER
	while [ -z $DISTRIB_RELEASE ]
	do
		[ "$AUTOFILL" ] || \
		if [ -z "$1" ]; then
			noask && return 1
			echo_ -n "Which ${DISTRIBUTION} release would you like? ["$DEFAULT_NUM"] "
			read $SHORT_READ ANSWER
			[ "$SHORT_READ" ] && echo_
		else
			echo_ $1
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
				wrong_num
			fi
		else
			wrong_res
		fi

		if [ -n "$1" ]; then
			break
		fi
	done
}

## Choose distribution type
function choose_distribution_type() {
	echo_
	echo_ "Choose ${DISTRIBUTION} type:"

	i=0
	local DISTRIBUTION_TYPE_ARRAY_LEN
	local DISTRIBUTION_TYPE_ELEMENT
	local DISTRIBUTION_TYPE

	DISTRIBUTION_TYPE_ARRAY_LEN=${DISTRIBUTION}_TYPE_ARRAY_LEN
	while [[ $i -lt ${!DISTRIBUTION_TYPE_ARRAY_LEN} ]]
	do
		DISTRIBUTION_TYPE_ARRAY_ELEMENT=${DISTRIBUTION}_TYPE_ARRAY[$i]
		DISTRIBUTION_TYPE_ARRAY_ELEMENT_DESC=${DISTRIBUTION}_TYPE_ARRAY_DESC[$i]
		DISTRIBUTION_TYPE=${!DISTRIBUTION_TYPE_ARRAY_ELEMENT}
		DISTRIBUTION_TYPE_DESC=${!DISTRIBUTION_TYPE_ARRAY_ELEMENT_DESC}
		echo_ "$((${i}+1)). ${DISTRIBUTION_TYPE} - ${DISTRIBUTION_TYPE_DESC=}"
		[ "$DISTRIBUTION_TYPE" = "$DISTRIB_TYPE" ] && return 0
		let i++
	done

	[ "$NOASK" -o "$AUTOFILL" ] || DISTRIB_TYPE=
	[ "$DISTRIB_TYPE" ] && return 1

	echo_

	local DEFAULT_NUM
	DEFAULT_NUM=1

	export DISTRIB_TYPE=
	local ANSWER
	while [ -z $DISTRIB_TYPE ]
	do
		[ "$AUTOFILL" ] || \
		if [ -z "$1" ]; then
			noask && return 1
			echo_ -n "Which ${DISTRIBUTION} type would you like? ["$DEFAULT_NUM"] "
			read $SHORT_READ ANSWER
			[ "$SHORT_READ" ] && echo_
		else
			echo_ $1
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
				wrong_num
			fi
		else
			wrong_res
		fi

		if [ -n "$1" ]; then
			break
		fi
	done
}

## Choose distribution arch
function choose_distribution_architecture() {
	echo_
	echo_ "Set architecture to 'arm64' by default."
	DISTRIB_ARCH="arm64"
	export DISTRIB_ARCH
}

function choose_install_type() {
	echo_
	echo_ "Choose install type:"
	# FIXME
	if [ "$UBOOT" == "mainline" -o "$LINUX" == "mainline" ]; then
		INSTALL_TYPE_ARRAY=("SD-USB")
		INSTALL_TYPE_ARRAY_DESC=("Image For Writing to SD/USB Storage")
		INSTALL_TYPE_ARRAY_LEN=${#INSTALL_TYPE_ARRAY[@]}
	fi
	i=0
	while [[ $i -lt $INSTALL_TYPE_ARRAY_LEN ]]
	do
		echo_ "$((${i}+1)). ${INSTALL_TYPE_ARRAY[$i]} - ${INSTALL_TYPE_ARRAY_DESC[$i]}"
		[ "${INSTALL_TYPE_ARRAY[$i]}" = "$INSTALL_TYPE" ] && return 0
		let i++
	done

	[ "$NOASK" -o "$AUTOFILL" ] || INSTALL_TYPE=
	[ "$INSTALL_TYPE" ] && return 1

	echo_

	local DEFAULT_NUM
	DEFAULT_NUM=1

	export INSTALL_TYPE=
	local ANSWER
	while [ -z $INSTALL_TYPE ]
	do
		[ "$AUTOFILL" ] || \
		if [ -z "$1" ]; then
			noask && return 1
			echo_ -n "Which install type would you like? ["$DEFAULT_NUM"] "
			read $SHORT_READ ANSWER
			[ "$SHORT_READ" ] && echo_
		else
			echo_ $1
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
				wrong_num
			fi
		else
			wrong_res
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

	if [ "$KHADAS_BOARD" == "Generic" ]; then
		VENDOR="Generic"
		CHIP="Generic"
	fi

	local v p p_

	for p in $CONFIG_ARGS $CONFIG_ADDS; do
		eval v=\$$p && [ "$v" ] && p_="$p_ $p=$v"
	done

	echo2 "\

== ENV CONFIG =======================
VERSION=$VERSION\
${p_// /$'\n'}

== ONE LINE CONFIG ==================
source $BASH_SOURCE -q -s $p_
"
	echo2 "Environment setup done. Type 'make' to build."
}

ask_yes_no(){
    local v a n A
    case $3 in
	Y|y|yes|Yes|YES|1) a=yes; n=n; A=Y ;;
	N|n|No|NO|0)       a=no;  n=y; A=N ;;
    esac
    echo_
    eval v=\$$1
    while [ "1" ] ; do
    #[ "$v" ] || \
    echo_ -n "$2 [$A|$n] "

    [ "$AUTOFILL" ] && v=${v:-$A}
    [ "$NOASK" ] || [ "$v" ] || read $SHORT_READ v

    case $v in
	y|Y|Yes|YES|yes) export $1=yes; break ;;
	n|N|No|NO|no)    export $1=no ; break ;;
	"")
	[ "$NOASK" ] ||  export $1=$a ; break ;;
	*)
	echo_
	[ ! "$NOASK" ] || DIE "$1 have wrong value: $v" || return 1
	echo_ "Please press Y or N or Enter for default choose!"
	echo_
	unset v
	sleep 1
    esac
    done
    echo_
    oky $1
}

choose_image_types(){
    ask_yes_no COMPRESS_IMAGE \
    "Compress image?" N || return 1
    [ "$INSTALL_TYPE" == "SD-USB" ] && return
    ask_yes_no INSTALL_TYPE_RAW \
	"Generate RAW image (suitable for dd and krescue usage)?" N || return 1
}
#for e in $CONFIG_ARGS ; do
#	eval t_=\$$e
#	[ "$t_" ] && \
#		echo_ "[i] export $e=$t_"
#	export $e
#done

err(){
	local v; eval v=\$$1
	[ "$v" ] || DIE undefined $1 || return 1
	DIE $1 incorrect value $v    || return 1
}

oky(){
	local v; eval v=\$$1
	echo_ "=> $v"
}

# BEGIN

[ "$REUSE" ] && echo_ "[i] REUSE env mode"

export_version || err VERSION || return 1

echo_ "\
[i] FULL USAGE INFO: source $BASH_SOURCE --help
[i] press Ctrl+C for abort"

[ "$AUTOFILL" ] && \
	echo_ "[i] AUTOFILL mode by default values: enabled"

# automate next step if defined or ask

choose_khadas_board              || err KHADAS_BOARD    || return 1
oky KHADAS_BOARD

cd $ROOT                                                || return 1
source config/boards/${KHADAS_BOARD}.conf || { cd $CDIR;   return 1
}; cd $CDIR

[ ! "$UBOOT" -a "$LINUX" = "mainline" ] && \
    UBOOT=mainline

[ "$KHADAS_BOARD" != "Generic" ] && {
choose_uboot_version             || err UBOOT           || return 1
oky UBOOT
} || {
	UBOOT=NULL
}
choose_linux_version             || err LINUX           || return 1
oky LINUX
choose_distribution              || err DISTRIBUTION    || return 1
oky DISTRIBUTION
choose_distribution_release      || err DISTRIB_RELEASE || return 1
oky DISTRIB_RELEASE
choose_distribution_type         || err DISTRIB_TYPE    || return 1
oky DISTRIB_TYPE
choose_distribution_architecture || err DISTRIB_ARCH    || return 1
oky DISTRIB_ARCH
choose_install_type              || err INSTALL_TYPE    || return 1
oky INSTALL_TYPE

choose_image_types || return 1

lunch

# last step
unset_vars $LOCAL CONFIG_ARGS CONFIG_ADDS LOCAL CDIR SCRIPT
