#!/bin/sh
#
# Commands for ROM release
#

if [ "$1" == "16.04.2" ]; then
	APT_OPTIONS=
elif [ "$1" == "17.04" ] || [ "$1" == "17.10" ]; then
	APT_OPTIONS="--allow-unauthenticated"
else
	echo "Unsupported ubuntu version!"
	APT_OPTIONS=
	exit
fi

UBUNTU_ARCH=$2
INSTALL_TYPE=$3

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
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

# Locale
locale-gen "en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
update-locale LC_ALL="en_US.UTF-8" LANG="en_US.UTF-8" LC_MESSAGES=POSIX
dpkg-reconfigure -f noninteractive locales

sed -i "s/^# deb http/deb http/g" /etc/apt/sources.list

# Fetch the latest package lists from server
apt-get update

# Upgrade
apt-get -y $APT_OPTIONS upgrade

apt-get -y clean
apt-get -y autoclean

# Install the packages
apt-get -y $APT_OPTIONS install ifupdown net-tools udev fbset vim sudo initramfs-tools \
		bluez rfkill libbluetooth-dev mc \
		iputils-ping parted u-boot-tools

if [ "$UBUNTU_ARCH" == "arm64" ]; then
	# Install armhf library
	dpkg --add-architecture armhf
	apt-get update
	apt-get -y $APT_OPTIONS install libc6:armhf
fi

apt-get -y clean
apt-get -y autoclean

# Install Docker
#apt-get -y $APT_OPTIONS install lxc aufs-tools cgroup-lite apparmor docker.io
#usermod -aG docker khadas

# Build the ramdisk
mkinitramfs -o /boot/initrd.img `cat linux-version` 2>/dev/null

# Generate uInitrd
mkimage -A arm64 -O linux -T ramdisk -a 0x0 -e 0x0 -n "initrd"  -d /boot/initrd.img  /boot/uInitrd

if [ "$INSTALL_TYPE" == "EMMC" ]; then
	#Generate uImage
	mkimage -n 'linux-4.9' -A arm64 -O linux -T kernel -C none -a 0x1080000 -e 0x1080000 -d /boot/Image /boot/uImage

	# Create links
	ln -s /boot/uImage uImage
	ln -s /boot/uInitrd uInitrd
	ln -s /boot/kvim.dtb kvim.dtb
	ln -s /boot/kvim2.dtb kvim2.dtb

	# Backup
	cp /boot/uInitrd /boot/uInitrd.old
	cp /boot/uImage /boot/uImage.old
	ln -s /boot/uImage.old uImage.old
	ln -s /boot/uInitrd.old uInitrd.old
	ln -s /boot/kvim.dtb.old kvim.dtb.old
	ln -s /boot/kvim2.dtb.old kvim2.dtb.old
fi

# Load mali module
echo mali >> /etc/modules

# Load WIFI at boot time(MUST HERE)
echo dhd >> /etc/modules

# Load WIFI - for mainline
echo brcmfmac >> /etc/modules

# Load AUFS module
echo aufs >> /etc/modules

# Bluetooth
systemctl enable bluetooth-khadas

# Resize service
systemctl enable resize2fs

# HDMI service
systemctl enable 0hdmi

# Build time
LC_ALL="C" date > /etc/build-time

# Restore the sources.list from mirrors to original
if [ -f /etc/apt/sources.list.orig ]; then
	mv /etc/apt/sources.list.orig /etc/apt/sources.list
fi

# Clean up
rm /linux-version
apt-get -y clean
apt-get -y autoclean
#history -c

# Self-deleting
rm $0
