#!/bin/sh
#
# Commands for ROM release
#

if [ "$1" == "16.04" ]; then
	APT_OPTIONS=
elif [ "$1" == "17.04" ] || [ "$2" == "17.10" ]; then
	APT_OPTIONS="--allow-unauthenticated"
else
	echo "Unsupported ubuntu version!"
	APT_OPTIONS=
	exit
fi

INSTALL_TYPE=$2

# Setup DNS resolver
cp -arf /etc/resolv.conf /etc/resolv.conf.origin
rm -rf /etc/resolv.conf
echo "nameserver 127.0.1.1" > /etc/resolv.conf

sed -i "s/^# deb http/deb http/g" /etc/apt/sources.list

# Fetch the latest package lists from server
apt-get update

# Upgrade
apt-get -y $APT_OPTIONS upgrade

# Install linux debs
dpkg -i /tempdebs/linux-image-*.deb
dpkg -i /tempdebs/linux-dtb-*.deb
dpkg -i /tempdebs/linux-firmware-image-*.deb
dpkg -i /tempdebs/linux-headers-*.deb

# Build time
LC_ALL="C" date > /etc/build-time

# Restore the sources.list from mirrors to original
if [ -f /etc/apt/sources.list.orig ]; then
	mv /etc/apt/sources.list.orig /etc/apt/sources.list
fi

# Restore resolv.conf
rm -rf /etc/resolv.conf
mv /etc/resolv.conf.origin /etc/resolv.conf

# Clean up
rm linux-version
rm -rf /tempdebs
apt clean
#history -c

# Self-deleting
rm $0
