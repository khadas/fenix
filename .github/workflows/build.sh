#!/bin/bash

CONFIG=.github/workflows/configs/config-github-actions.conf

touch .ignore-update

if [ "$1" == "mainline" ]; then
	# Malinline u-boot & Mainline linux

	VIM_MAINLINE_LINUX=mainline
	VIM_MAINLINE_UBOOT=mainline
	EDGE_MAINLINE_LINUX=mainline
	EDGE_MAINLINE_UBOOT=mainline

	BOARDS="VIM1 VIM2 VIM3 VIM3L Edge"
	DISTRIB_TYPES="server gnome"

	sed -i 's/LINUX=.*/LINUX=${VIM_MAINLINE_LINUX}/g' $CONFIG
	sed -i 's/UBOOT=.*/UBOOT=${VIM_MAINLINE_UBOOT}/g' $CONFIG
	sed -i 's/INSTALL_TYPE=.*/INSTALL_TYPE=SD-USB/g' $CONFIG

	# Build mainline images
	for board in $BOARDS
	do
		sed -i 's/KHADAS_BOARD=.*/KHADAS_BOARD=${board}/g' $CONFIG
		for distrib_type in $DISTRIB_TYPES
		do
			sed -i 's/DISTRIB_TYPE=.*/DISTRIB_TYPE=${distrib_type}/g' $CONFIG
			source env/setenv.sh config $CONFIG
			sudo rm -rf build/images/.tmp/*
			BUILD_TYPE=release COMPRESS_IMAGE=yes NO_CCACHE=yes make
			sudo rm -rf build/images/*.img
		done
	done
elif [ "$1" == "legacy" ]; then
	# Legacy u-boot & Legacy linux

	VIM_LEGACY_LINUX=4.9
	VIM_LEGACY_UBOOT=2015.01
	VIM_LEGACY_IMAGE_DESKTOP=gnome
	EDGE_LEGACY_LINUX=4.4
	EDGE_LEGACY_UBOOT=2017.09
	EDGE_LEGACY_IMAGE_DESKTOP=lxde

	BOARDS="VIM1 VIM2 VIM3 VIM3L Edge"
	DISTRIB_TYPES="server gnome lxde"

	if [ "$2" == "EMMC" ]; then
		sed -i 's/INSTALL_TYPE=.*/INSTALL_TYPE=EMMC/g' $CONFIG
	else
		sed -i 's/INSTALL_TYPE=.*/INSTALL_TYPE=SD-USB/g' $CONFIG
	fi

	# Build legacy images
	for board in $BOARDS
	do
		sed -i 's/KHADAS_BOARD=.*/KHADAS_BOARD=${board}/g' $CONFIG
		if [ $board == Edge ]; then
			sed -i 's/LINUX=.*/LINUX=${EDGE_LEGACY_LINUX}/g' $CONFIG
			sed -i 's/UBOOT=.*/UBOOT=${EDGE_LEGACY_UBOOT}/g' $CONFIG
		else
			sed -i 's/LINUX=.*/LINUX=${VIM_LEGACY_LINUX}/g' $CONFIG
			sed -i 's/UBOOT=.*/UBOOT=${VIM_LEGACY_UBOOT}/g' $CONFIG
		fi
		for distrib_type in $DISTRIB_TYPES
		do
			if [ $board == Edge -a $distrib_type == $VIM_LEGACY_IMAGE_DESKTOP ]; then
				continue
			elif [ $board != Edge -a $distrib_type == $EDGE_LEGACY_IMAGE_DESKTOP ]; then
				continue
			fi
			sed -i 's/DISTRIB_TYPE=.*/DISTRIB_TYPE=${distrib_type}/g' $CONFIG
			source env/setenv.sh config $CONFIG
			sudo rm -rf build/images/.tmp/*
			BUILD_TYPE=release COMPRESS_IMAGE=yes NO_CCACHE=yes make
			sudo rm -rf build/images/*.img
		done
	done
fi

exit
