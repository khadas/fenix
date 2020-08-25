#!/bin/bash

CONFIG=.github/workflows/configs/config-github-actions.conf

touch .ignore-update

# Malinline u-boot & Mainline linux

# Build image for VIM1
## Server
sed -i 's/KHADAS_BOARD=.*/KHADAS_BOARD=VIM1/g' $CONFIG
sed -i 's/DISTRIB_TYPE=.*/DISTRIB_TYPE=server/g' $CONFIG
source env/setenv.sh config $CONFIG
sudo rm -rf build/images/.tmp/*
BUILD_TYPE=release COMPRESS_IMAGE=yes NO_CCACHE=yes make
sudo rm -rf build/images/*.img
## Desktop
sed -i 's/DISTRIB_TYPE=.*/DISTRIB_TYPE=gnome/g' $CONFIG
source env/setenv.sh config $CONFIG
sudo rm -rf build/images/.tmp/*
BUILD_TYPE=release COMPRESS_IMAGE=yes NO_CCACHE=yes make
sudo rm -rf build/images/*.img

# Build image for VIM2
## Server
sed -i 's/KHADAS_BOARD=.*/KHADAS_BOARD=VIM2/g' $CONFIG
sed -i 's/DISTRIB_TYPE=.*/DISTRIB_TYPE=server/g' $CONFIG
source env/setenv.sh config $CONFIG
sudo rm -rf build/images/.tmp/*
BUILD_TYPE=release COMPRESS_IMAGE=yes NO_CCACHE=yes make
sudo rm -rf build/images/*.img
## Desktop
sed -i 's/DISTRIB_TYPE=.*/DISTRIB_TYPE=gnome/g' $CONFIG
source env/setenv.sh config $CONFIG
sudo rm -rf build/images/.tmp/*
BUILD_TYPE=release COMPRESS_IMAGE=yes NO_CCACHE=yes make
sudo rm -rf build/images/*.img

# Build image for VIM3
## Server
sed -i 's/KHADAS_BOARD=.*/KHADAS_BOARD=VIM3/g' $CONFIG
sed -i 's/DISTRIB_TYPE=.*/DISTRIB_TYPE=server/g' $CONFIG
source env/setenv.sh config $CONFIG
sudo rm -rf build/images/.tmp/*
BUILD_TYPE=release COMPRESS_IMAGE=yes NO_CCACHE=yes make
sudo rm -rf build/images/*.img
## Desktop
sed -i 's/DISTRIB_TYPE=.*/DISTRIB_TYPE=gnome/g' $CONFIG
source env/setenv.sh config $CONFIG
sudo rm -rf build/images/.tmp/*
BUILD_TYPE=release COMPRESS_IMAGE=yes NO_CCACHE=yes make
sudo rm -rf build/images/*.img

# Build image for VIM3L
## Server
sed -i 's/KHADAS_BOARD=.*/KHADAS_BOARD=VIM3L/g' $CONFIG
sed -i 's/DISTRIB_TYPE=.*/DISTRIB_TYPE=server/g' $CONFIG
source env/setenv.sh config $CONFIG
sudo rm -rf build/images/.tmp/*
BUILD_TYPE=release COMPRESS_IMAGE=yes NO_CCACHE=yes make
sudo rm -rf build/images/*.img
## Desktop
sed -i 's/DISTRIB_TYPE=.*/DISTRIB_TYPE=gnome/g' $CONFIG
source env/setenv.sh config $CONFIG
sudo rm -rf build/images/.tmp/*
BUILD_TYPE=release COMPRESS_IMAGE=yes NO_CCACHE=yes make
sudo rm -rf build/images/*.img

# Build image for Edge
## Server
sed -i 's/KHADAS_BOARD=.*/KHADAS_BOARD=Edge/g' $CONFIG
sed -i 's/DISTRIB_TYPE=.*/DISTRIB_TYPE=server/g' $CONFIG
source env/setenv.sh config $CONFIG
sudo rm -rf build/images/.tmp/*
BUILD_TYPE=release COMPRESS_IMAGE=yes NO_CCACHE=yes make
sudo rm -rf build/images/*.img
## Desktop
sed -i 's/DISTRIB_TYPE=.*/DISTRIB_TYPE=gnome/g' $CONFIG
source env/setenv.sh config $CONFIG
sudo rm -rf build/images/.tmp/*
BUILD_TYPE=release COMPRESS_IMAGE=yes NO_CCACHE=yes make
sudo rm -rf build/images/*.img

# Legacy u-boot & Legacy linux

## TODO ##

exit
