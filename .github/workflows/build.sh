#!/bin/bash

CONFIG=.github/workflows/configs/config-github-actions.conf

touch .ignore-update

LINUX=$1
BOARD=$2

if [ "$LINUX" == "mainline" ]; then
	# Malinline u-boot & Mainline linux

	VIM_MAINLINE_LINUX=mainline
	VIM_MAINLINE_UBOOT=mainline
	EDGE_MAINLINE_LINUX=mainline
	EDGE_MAINLINE_UBOOT=mainline

	DISTRIB_TYPES="server gnome"
	if [ "$BOARD" == "Edge" ]; then
		INSTALL_TYPES="EMMC SD-USB"
	else
		INSTALL_TYPES="SD-USB"
	fi

	sed -i 's/LINUX=.*/LINUX=${VIM_MAINLINE_LINUX}/g' $CONFIG
	sed -i 's/UBOOT=.*/UBOOT=${VIM_MAINLINE_UBOOT}/g' $CONFIG
	sed -i 's/KHADAS_BOARD=.*/KHADAS_BOARD=${BOARD}/g' $CONFIG

	# Build mainline images
	for install_type in $INSTALL_TYPES
	do
		sed -i 's/INSTALL_TYPE=.*/INSTALL_TYPE=${install_type}/g' $CONFIG
		for distrib_type in $DISTRIB_TYPES
		do
			sed -i 's/DISTRIB_TYPE=.*/DISTRIB_TYPE=${distrib_type}/g' $CONFIG
			source env/setenv.sh config $CONFIG
			sudo rm -rf build/images/.tmp/*
			BUILD_TYPE=release COMPRESS_IMAGE=yes NO_CCACHE=yes make
			sudo rm -rf build/images/*.img
		done
	done
elif [ "$LINUX" == "legacy" ]; then
	# Legacy u-boot & Legacy linux

	VIM_LEGACY_LINUX=4.9
	VIM_LEGACY_UBOOT=2015.01
	EDGE_LEGACY_LINUX=4.4
	EDGE_LEGACY_UBOOT=2017.09

	if [ "$BOARD" == "Edge" ]; then
		sed -i 's/LINUX=.*/LINUX=${EDGE_LEGACY_LINUX}/g' $CONFIG
		sed -i 's/UBOOT=.*/UBOOT=${EDGE_LEGACY_UBOOT}/g' $CONFIG
		DISTRIB_TYPES="server lxde"
	else
		sed -i 's/LINUX=.*/LINUX=${VIM_LEGACY_LINUX}/g' $CONFIG
		sed -i 's/UBOOT=.*/UBOOT=${VIM_LEGACY_UBOOT}/g' $CONFIG
		DISTRIB_TYPES="server gnome"
	fi

	INSTALL_TYPES="EMMC SD-USB"

	sed -i 's/KHADAS_BOARD=.*/KHADAS_BOARD=${BOARD}/g' $CONFIG

	# Build legacy images
	for install_type in $INSTALL_TYPES
	do
		sed -i 's/INSTALL_TYPE=.*/INSTALL_TYPE=${install_type}/g' $CONFIG
		for distrib_type in $DISTRIB_TYPES
		do
			sed -i 's/DISTRIB_TYPE=.*/DISTRIB_TYPE=${distrib_type}/g' $CONFIG
			source env/setenv.sh config $CONFIG
			sudo rm -rf build/images/.tmp/*
			BUILD_TYPE=release COMPRESS_IMAGE=yes NO_CCACHE=yes make
			sudo rm -rf build/images/*.img
		done
	done
fi

exit
