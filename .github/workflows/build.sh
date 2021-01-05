#!/bin/bash

touch .ignore-update

LINUX=$1
BOARD=$2
DISTRIBUTION=$3

CONFIG=.github/workflows/configs/config-${DISTRIBUTION,,}-github-actions.conf

if [ "$BOARD" == "Edge" ]; then
	INSTALL_TYPES="EMMC SD-USB"
else
	if [ "$LINUX" == "mainline" ]; then
		INSTALL_TYPES="SD-USB"
	else
		INSTALL_TYPES="EMMC SD-USB"
	fi
fi

if [ "$LINUX" == "mainline" ]; then
	LINUX_VER="mainline"
	UBOOT_VER="mainline"
	if [ "$DISTRIBUTION" == "Ubuntu" ]; then
		DISTRIB_TYPES="minimal server gnome"
	else
		DISTRIB_TYPES="minimal server xfce"
	fi
else
	if [ "$BOARD" == "Edge" ]; then
		LINUX_VER="4.4"
		UBOOT_VER="2017.09"
		DISTRIB_TYPES="minimal server lxde"
	else
		LINUX_VER="4.9"
		UBOOT_VER="2015.01"
		if [ "$DISTRIBUTION" == "Ubuntu" ]; then
			DISTRIB_TYPES="minimal server gnome"
		else
			DISTRIB_TYPES="minimal server xfce"
		fi
	fi
fi

sed -i 's/LINUX=.*/LINUX=${LINUX_VER}/g' $CONFIG
sed -i 's/UBOOT=.*/UBOOT=${UBOOT_VER}/g' $CONFIG
sed -i 's/KHADAS_BOARD=.*/KHADAS_BOARD=${BOARD}/g' $CONFIG

for install_type in $INSTALL_TYPES
do
	sed -i 's/INSTALL_TYPE=.*/INSTALL_TYPE=${install_type}/g' $CONFIG
	for distrib_type in $DISTRIB_TYPES
	do
		sed -i 's/DISTRIB_TYPE=.*/DISTRIB_TYPE=${distrib_type}/g' $CONFIG
		source env/setenv.sh config $CONFIG
		sudo rm -rf build/images/.tmp/*
		BUILD_TYPE=release COMPRESS_IMAGE=yes NO_CCACHE=yes make || BUILD_TYPE=release COMPRESS_IMAGE=yes NO_CCACHE=yes make
		BUILD_TYPE=release COMPRESS_IMAGE=yes NO_CCACHE=yes INSTALL_TYPE_RAW=yes make image || BUILD_TYPE=release COMPRESS_IMAGE=yes NO_CCACHE=yes INSTALL_TYPE_RAW=yes make image
		sudo rm -rf build/images/*.img
	done
done

exit
