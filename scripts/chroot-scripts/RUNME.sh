#!/bin/sh
#
# Commands for ROM release
#

#set -e -o pipefail

DISTRIBUTION=$1
DISTRIB_RELEASE=$2
DISTRIB_TYPE=$3
DISTRIB_ARCH=$4
KHADAS_BOARD=$5
LINUX=$6
UBOOT=$7
INSTALL_TYPE=$8
VENDER=$9

export LC_ALL=C
export LANG=C

# Setup password for root user
echo root:khadas | chpasswd

# Admin user khadas
useradd -m -p "pal8k5d7/m9GY" -s /bin/bash khadas
usermod -aG sudo,adm khadas

# Add group
DEFGROUPS="audio,video,disk,input,tty,root,users,games,dialout,cdrom,dip,plugdev,bluetooth,pulse-access,systemd-journal,netdev,staff"
IFS=','
for group in $DEFGROUPS; do
	/bin/egrep  -i "^$group" /etc/group > /dev/null
	if [ $? -eq 0 ]; then
		echo "Group '$group' exists in /etc/group"
	else
		echo "Group '$group' does not exists in /etc/group, creating"
		groupadd $group
	fi
done
unset IFS

echo "Add khadas to ($DEFGROUPS) groups."
usermod -a -G $DEFGROUPS khadas

# Setup host
echo Khadas > /etc/hostname
# set hostname in hosts file
cat <<-EOF > /etc/hosts
127.0.0.1   localhost Khadas
::1         localhost Khadas ip6-localhost ip6-loopback
fe00::0     ip6-localnet
ff00::0     ip6-mcastprefix
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EOF

if [ "$DISTRIB_TYPE" != "server" ]; then
	# Enable network manager
	if [ -f /etc/NetworkManager/NetworkManager.conf ]; then
		sed "s/managed=\(.*\)/managed=true/g" -i /etc/NetworkManager/NetworkManager.conf
		# Disable dns management withing NM
		sed "s/\[main\]/\[main\]\ndns=none/g" -i /etc/NetworkManager/NetworkManager.conf
		printf '[keyfile]\nunmanaged-devices=interface-name:p2p0\n' >> /etc/NetworkManager/NetworkManager.conf
	fi
fi

if [ "$DISTRIB_TYPE" != "server" ] && [ "$LINUX" == "mainline" ] && [ "$DISTRIB_ARCH" == "arm64" ]; then

	# OpenGL ES
	apt-get install -y mesa-utils-extra

	# disable mesa EGL libs
	rm /etc/ld.so.conf.d/*_EGL.conf
	ldconfig

	apt-get install -y build-essential libtool automake autoconf xutils-dev xserver-xorg-dev xorg-dev libudev-dev

	cd xf86-video-armsoc
	./autogen.sh
	./configure --prefix=/usr
	make install
	mkdir -p /etc/X11
	cp xorg.conf /etc/X11/
	cd -
	rm -rf xf86-video-armsoc

	# Clean up dev packages
	apt-get purge -y build-essential libtool automake autoconf xutils-dev xserver-xorg-dev xorg-dev libudev-dev
	apt-get -y autoremove

	# Clean up packages
	apt-get -y clean
	apt-get -y autoclean
fi

cd /

if [ "$INSTALL_TYPE" == "EMMC" ]; then

	# Create links
	ln -s /boot/zImage zImage
	ln -s /boot/uInitrd uInitrd

	if [ "$KHADAS_BOARD" == "VIM" ]; then
		ln -s /boot/dtb/kvim_linux.dtb dtb.img
	elif [ "$KHADAS_BOARD" == "VIM2" ]; then
		ln -s /boot/dtb/kvim2_linux.dtb dtb.img
	elif [ "$KHADAS_BOARD" == "Edge" ]; then
		ln -s /boot/dtb/rk3399-kedge-linux.dtb dtb.img
	elif [ "$KHADAS_BOARD" == "Firefly_RK3399" ]; then
		ln -s /boot/dtb/rk3399-firefly-linux.dtb dtb.img
	fi
fi

# Bluetooth
systemctl enable bluetooth-khadas

# Resize service
systemctl enable resize2fs

# HDMI service
systemctl enable 0hdmi

# Build time
LC_ALL="C" date > /etc/build-time

# Clean up
apt-get -y clean
apt-get -y autoclean
#history -c

# Self-deleting
rm $0
