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

# Setup host
echo Khadas > /etc/hostname
echo "127.0.0.1    localhost.localdomain localhost" > /etc/hosts
echo "127.0.0.1    Khadas" >> /etc/hosts

# Setup DNS resolver
cp -arf /etc/resolv.conf /etc/resolv.conf.origin
rm -rf /etc/resolv.conf
echo "nameserver 127.0.1.1" > /etc/resolv.conf

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

# Fixup /media/khadas ACL attribute
setfacl -m u:khadas:rx /media/khadas
setfacl -m g::--- /media/khadas

# Fixup network-manager
cd /etc/init.d/
update-rc.d khadas-restart-nm.sh defaults 99
cd -

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

# Restore the sources.list from mirrors to original
if [ -f /etc/apt/sources.list.orig ]; then
	mv /etc/apt/sources.list.orig /etc/apt/sources.list
fi

# Restore resolv.conf
rm -rf /etc/resolv.conf
mv /etc/resolv.conf.origin /etc/resolv.conf

# Clean up
rm linux-version
apt clean
#history -c

# Self-deleting
rm $0
