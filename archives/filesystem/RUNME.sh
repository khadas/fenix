#!/bin/sh
#
# Commands for ROM release
#

# Setup password for root user
echo root:khadas | chpasswd

# Admin user khadas
useradd -m -p "pal8k5d7/m9GY" -s /bin/bash khadas
usermod -aG sudo,adm khadas

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

sed -i "s/^# deb http/deb http/g" /etc/apt/sources.list

# Fetch the latest package lists from server
apt-get update

# Upgrade
apt-get -y --allow-unauthenticated upgrade

# Install the packages
apt-get -y --allow-unauthenticated  install ifupdown net-tools udev fbset vim sudo initramfs-tools \
		bluez rfkill libbluetooth-dev \
		iputils-ping

# Install armhf library
dpkg --add-architecture armhf
apt-get --allow-unauthenticated update
apt-get -y --allow-unauthenticated install libc6:armhf

# Install Docker
apt-get -y --allow-unauthenticated install lxc aufs-tools cgroup-lite apparmor docker.io
usermod -aG docker khadas

# Build the ramdisk
mkinitramfs -o /boot/initrd.img `cat linux-version` 2>/dev/null

# Generate uInitrd
mkimage -A arm64 -O linux -T ramdisk -a 0x0 -e 0x0 -n "initrd"  -d /boot/initrd.img  /boot/uInitrd

#Generate uImage
mkimage -n 'linux-4.9' -A arm64 -O linux -T kernel -C none -a 0x1080000 -e 0x1080000 -d /boot/Image /boot/uImage

# Create links
ln -s /boot/uImage uImage
ln -s /boot/uInitrd uInitrd
ln -s /boot/kvim.dtb kvim.dtb
ln -s /boot/kvim2.dtb kvim2.dtb

# Load WIFI at boot time(MUST HERE)
echo dhd >> /etc/modules

# Load WIFI - for mainline
echo brcmfmac >> /etc/modules

# Load AUFS module
echo aufs >> /etc/modules

# Bluetooth
systemctl enable bluetooth-khadas

# Restore the sources.list from mirrors to original
if [ -f /etc/apt/sources.list.orig ]; then
	mv /etc/apt/sources.list.orig /etc/apt/sources.list
fi

# Clean up
rm linux-version
apt clean
#history -c

# Self-deleting
rm $0
