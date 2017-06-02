#!/bin/sh
#
# Commands for ROM release
#

# Setup password for root user
echo root:khadas | chpasswd

# Setup host
echo Khadas > /etc/hostname
echo "127.0.0.1    localhost.localdomain localhost" > /etc/hosts
echo "127.0.0.1    Khadas" >> /etc/hosts

# Setup DNS resolver
echo "nameserver 127.0.1.1" > /etc/resolv.conf

# Mali GPU
cd /usr/lib
ln -s libMali.so libGLESv2.so.2.0
ln -s libGLESv2.so.2.0 libGLESv2.so.2
ln -s libGLESv2.so.2 libGLESv2.so
ln -s libMali.so libGLESv1_CM.so.1.1
ln -s libGLESv1_CM.so.1.1 libGLESv1_CM.so.1
ln -s libGLESv1_CM.so.1 libGLESv1_CM.so
ln -s libMali.so libEGL.so.1.4
ln -s libEGL.so.1.4 libEGL.so.1
ln -s libEGL.so.1 libEGL.so
cd -

# Fetch the latest package lists from server
apt update

# Upgrade
apt -y upgrade

# Install the packages
apt -y install ifupdown net-tools udev fbset vim sudo initramfs-tools \
		bluez rfkill libbluetooth-dev \
		iputils-ping

# Build the ramdisk
mkinitramfs -o /boot/initrd.img `cat linux-version` 2>/dev/null

# Load WIFI at boot time(MUST HERE)
echo dhd >> /etc/modules

# Bluetooth
systemctl enable bluetooth-khadas

# Restore the sources.list from mirrors to original
if [ -f /etc/apt/sources.list.orig ]; then
	mv /etc/apt/sources.list.orig /etc/apt/sources.list
fi

# Clean up
rm linux-version
#apt clean
#history -c

# Self-deleting
rm $0
