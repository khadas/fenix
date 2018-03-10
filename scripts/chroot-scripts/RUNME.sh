#!/bin/sh
#
# Commands for ROM release
#

#set -e -o pipefail

if [ "$1" == "16.04" ]; then
	APT_OPTIONS=
elif [ "$1" == "17.04" ] || [ "$1" == "17.10" ]; then
	APT_OPTIONS="--allow-unauthenticated"
else
	echo "Unsupported ubuntu version!"
	APT_OPTIONS=
	exit
fi

UBUNTU_TYPE=$2
UBUNTU_ARCH=$3
INSTALL_TYPE=$4
UBUNTU_MATE_ROOTFS_TYPE=$5
LINUX=$6
KHADAS_BOARD=$7

PACKAGE_LIST_BASIC="ifupdown net-tools udev fbset vim sudo initramfs-tools bluez rfkill libbluetooth-dev mc \
	iputils-ping parted u-boot-tools linux-base"

PACKAGE_LIST_ESSENTIAL="bc bridge-utils build-essential cpufrequtils device-tree-compiler \
	figlet fbset fping iw fake-hwclock wpasupplicant psmisc ntp parted rsync sudo curl dialog crda \
	wireless-regdb ncurses-term python3-apt sysfsutils toilet u-boot-tools unattended-upgrades \
	usbutils wireless-tools console-setup unicode-data openssh-server \
	ca-certificates resolvconf expect rcconf iptables mc abootimg man-db wget"

PACKAGE_LIST_ADDITIONAL="alsa-utils btrfs-tools dosfstools hddtemp iotop stress sysbench screen ntfs-3g vim pciutils \
	evtest htop pv lsof apt-transport-https libfuse2 libdigest-sha-perl libproc-processtable-perl aptitude dnsutils f3 haveged \
	hdparm rfkill vlan sysstat bash-completion hostapd git ethtool network-manager unzip ifenslave command-not-found lirc \
	libpam-systemd iperf3 software-properties-common libnss-myhostname f2fs-tools avahi-autoipd iputils-arping"

PACKAGE_LIST_DESKTOP="xserver-xorg xserver-xorg-video-fbdev gvfs-backends gvfs-fuse xfonts-base xinit x11-xserver-utils xterm thunar-volman \
	gksu bluetooth network-manager-gnome network-manager-openvpn-gnome gnome-keyring gcr libgck-1-0 libgcr-3-common p11-kit pasystray pavucontrol pulseaudio \
	paman pavumeter pulseaudio-module-gconf bluez bluez-tools pulseaudio-module-bluetooth blueman libgl1-mesa-dri gparted synaptic \
	policykit-1 mesa-utils lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings"

PACKAGE_LIST_MATE="mate-desktop-environment-extras mate-media mate-screensaver mate-utils mate-power-manager mate-applets ubuntu-mate-lightdm-theme mozo \
	nano linux-firmware zram-config chromium-browser gnome-icon-theme-full language-selector-gnome system-config-printer-gnome gnome-mplayer"

PACKAGE_LIST_OFFICE="lxtask mirage galculator hexchat mpv \
	gtk2-engines gtk2-engines-murrine gtk2-engines-pixbuf libgtk2.0-bin gcj-jre-headless libgnome2-perl \
	network-manager-gnome network-manager-openvpn-gnome gnome-keyring gcr libgck-1-0 libgcr-3-common p11-kit pasystray pavucontrol pulseaudio \
	libpam-gnome-keyring thunderbird system-config-printer-common numix-gtk-theme paprefs tango-icon-theme \
	libreoffice-writer libreoffice-style-tango libreoffice-gtk fbi cups-pk-helper cups"

PACKAGE_LIST_DOCKER="lxc aufs-tools cgroup-lite apparmor docker.io"

if [ "$UBUNTU_MATE_ROOTFS_TYPE" != "mate-rootfs" ]; then
	# Setup password for root user
	echo root:khadas | chpasswd

	# Admin user khadas
	useradd -m -p "pal8k5d7/m9GY" -s /bin/bash khadas
	usermod -aG sudo,adm khadas
fi

# Setup host
echo Khadas > /etc/hostname
echo "127.0.0.1    localhost.localdomain localhost" > /etc/hosts
echo "127.0.0.1    Khadas" >> /etc/hosts

adduser khadas audio
adduser khadas dialout
adduser khadas video

if [ "$UBUNTU_TYPE" == "mate" ] && [ "$UBUNTU_MATE_ROOTFS_TYPE" == "mate-rootfs" ]; then
	# Setup DNS resolver
	cp -arf /etc/resolv.conf /etc/resolv.conf.origin
	rm -rf /etc/resolv.conf
fi

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

apt-get -y $APT_OPTIONS install $PACKAGE_LIST_BASIC

if [ "$UBUNTU_TYPE" == "mate" ]; then
	apt-get -y $APT_OPTIONS install $PACKAGE_LIST_ESSENTIAL
	apt-get -y clean
	apt-get -y autoclean
	apt-get -y $APT_OPTIONS install $PACKAGE_LIST_ADDITIONAL
	apt-get -y clean
	apt-get -y autoclean
	apt-get -y $APT_OPTIONS install $PACKAGE_LIST_DESKTOP
	apt-get -y clean
	apt-get -y autoclean
	apt-get -y $APT_OPTIONS install $PACKAGE_LIST_MATE
	apt-get -y clean
	apt-get -y autoclean
	apt-get -y $APT_OPTIONS install $PACKAGE_LIST_OFFICE
fi

if [ "$UBUNTU_ARCH" == "arm64" ]; then
	# Install armhf library
	dpkg --add-architecture armhf
	apt-get update
	apt-get -y $APT_OPTIONS install libc6:armhf
fi

apt-get -y clean
apt-get -y autoclean

# Install Docker
#apt-get -y $APT_OPTIONS install $PACKAGE_LIST_DOCKER
#usermod -aG docker khadas

apt-get -y clean
apt-get -y autoclean

if [ "$UBUNTU_TYPE" == "mate" ] && [ "$UBUNTU_MATE_ROOTFS_TYPE" == "mate-rootfs" ]; then
	# Fixup /media/khadas ACL attribute
	setfacl -m u:khadas:rx /media/khadas
	setfacl -m g::--- /media/khadas

	# FIXME Mate rootfs need update!
	if [ "$INSTALL_TYPE" == "SD-USB" ]; then
		rm -rf /etc/default/FIRSTBOOT
	fi

	# Fixup network-manager
	cd /etc/init.d/
	update-rc.d khadas-restart-nm.sh defaults 99
	cd -
fi

if [ "$UBUNTU_TYPE" == "mate" ]; then
	# Enable network manager
	if [ -f /etc/NetworkManager/NetworkManager.conf ]; then
		sed "s/managed=\(.*\)/managed=true/g" -i /etc/NetworkManager/NetworkManager.conf
		# Disable dns management withing NM
		sed "s/\[main\]/\[main\]\ndns=none/g" -i /etc/NetworkManager/NetworkManager.conf
		printf '[keyfile]\nunmanaged-devices=interface-name:p2p0\n' >> /etc/NetworkManager/NetworkManager.conf
	fi
fi

if [ "$UBUNTU_TYPE" == "mate" ] && [ "$LINUX" == "mainline" ] && [ "$UBUNTU_ARCH" == "arm64" ]; then

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

if [ "$UBUNTU_TYPE" == "mate" ] && [ "$KHADAS_BOARD" == "VIM" ] && [ "$LINUX" == "3.14" ]; then
	# Install amremote
	if [ -f /tempdebs/pkg-aml-amremote_*.deb ]; then
		dpkg -i /tempdebs/pkg-aml-amremote_*.deb
		rm -rf /tempdebs/pkg-aml-amremote_*.deb

		# Enable khadas remote
		cp /boot/remote.conf.vim /boot/remote.conf

		systemctl --no-reload enable amlogic-remotecfg.service
	fi

	# Install libamcodec
	if [ -f /tempdebs/pkg-aml-codec_*.deb ]; then
		dpkg -i /tempdebs/pkg-aml-codec_*.deb
		rm -rf /tempdebs/pkg-aml-codec_*.deb
	fi

	# Install kodi
	if [ -f /tempdebs/pkg-aml-kodi_*.deb ]; then
		dpkg -i /tempdebs/pkg-aml-kodi_*.deb
		rm -rf /tempdebs/pkg-aml-kodi_*.deb
	fi

	usermod -a -G audio,video,disk,input,tty,root,users,games khadas
fi

cd /

# Install GPU deb
if [ -f /tempdebs/linux-gpu-*.deb ]; then
	dpkg -i /tempdebs/linux-gpu-*.deb
fi

# Install board package
dpkg -i /tempdebs/linux-board-package-*.deb

# Install linux debs
dpkg -i /tempdebs/linux-image-*.deb
dpkg -i /tempdebs/linux-dtb-*.deb
dpkg -i /tempdebs/linux-firmware-image-*.deb
dpkg -i /tempdebs/linux-headers-*.deb

if [ "$INSTALL_TYPE" == "EMMC" ]; then

	# Create links
	ln -s /boot/zImage zImage
	ln -s /boot/uInitrd uInitrd

	if [ "$KHADAS_BOARD" == "VIM" ]; then
		ln -s /boot/dtb/kvim_linux.dtb dtb.img
	elif [ "$KHADAS_BOARD" == "VIM2" ]; then
		ln -s /boot/dtb/kvim2_linux.dtb dtb.img
	fi
fi

if [ "$LINUX" == "3.14" ]; then
	echo dwc3 >> /etc/modules
	echo dwc_otg >> /etc/modules
fi

if [ "$KHADAS_BOARD" == "VIM" ]; then
	# Load mali module
	echo mali >> /etc/modules
fi

if [ "$LINUX" == "mainline" ]; then
	# Load WIFI - for mainline
	echo brcmfmac >> /etc/modules
else
	# Load WIFI at boot time(MUST HERE)
	echo dhd >> /etc/modules
fi

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

# Restore resolv.conf
if [ -L /etc/resolv.conf.origin ]; then
	rm -rf /etc/resolv.conf
	mv /etc/resolv.conf.origin /etc/resolv.conf
fi

# Clean up
rm /linux-version
rm -rf /tempdebs
apt-get -y clean
apt-get -y autoclean
#history -c

# Self-deleting
rm $0
