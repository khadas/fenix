#!/bin/sh
#
# Commands for ROM release
#

#set -e -o pipefail

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
UBUNTU_MATE_ROOTFS_TYPE=$4
LINUX=$5
KHADAS_BOARD=$6

if [ "$UBUNTU_MATE_ROOTFS_TYPE" == "mate-rootfs" ]; then
	# Setup host
	echo Khadas > /etc/hostname
	echo "127.0.0.1    localhost.localdomain localhost" > /etc/hosts
	echo "127.0.0.1    Khadas" >> /etc/hosts

	adduser khadas audio
	adduser khadas dialout
	adduser khadas video

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

	## Mirrors
	cp -a /etc/apt/sources.list /etc/apt/sources.list.orig
	sed -i "s/http:\/\/ports.ubuntu.com\/ubuntu-ports\//http:\/\/mirrors.ustc.edu.cn\/ubuntu-ports\//g" /etc/apt/sources.list

	# Fetch the latest package lists from server
	apt-get update

	# Upgrade
	apt-get -y $APT_OPTIONS upgrade

	apt-get -y clean
	apt-get -y autoclean

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
elif [ "$UBUNTU_MATE_ROOTFS_TYPE" == "chroot-install" ]; then
	# Setup password for root user
	echo root:khadas | chpasswd

	# Admin user khadas
	useradd -m -p "pal8k5d7/m9GY" -s /bin/bash khadas
	usermod -aG sudo,adm khadas

	adduser khadas audio
	adduser khadas dialout
	adduser khadas video

	# Setup host
	echo Khadas > /etc/hostname
	echo "127.0.0.1    localhost.localdomain localhost" > /etc/hosts
	echo "127.0.0.1    Khadas" >> /etc/hosts

	# Setup DNS resolver
	echo "nameserver 127.0.1.1" > /etc/resolv.conf

	# Locale
	locale-gen "en_US.UTF-8"
	export LC_ALL="en_US.UTF-8"
	update-locale LC_ALL="en_US.UTF-8" LANG="en_US.UTF-8" LC_MESSAGES=POSIX
	dpkg-reconfigure -f noninteractive locales

	## Apt sources.list: add [universe] and [multiverse] repositories
	sed -i "s/^# deb http/deb http/g" /etc/apt/sources.list

	## Mirrors
	cp -a /etc/apt/sources.list /etc/apt/sources.list.orig
	sed -i "s/http:\/\/ports.ubuntu.com\/ubuntu-ports\//http:\/\/mirrors.ustc.edu.cn\/ubuntu-ports\//g" /etc/apt/sources.list

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

	# Essential packagebreoffice-writer libreoffice-style-tango libreoffice-gtk fbi cups-pk-helper cupss
	apt-get install -y bc bridge-utils build-essential cpufrequtils device-tree-compiler figlet fbset fping \
		iw fake-hwclock wpasupplicant psmisc ntp parted rsync sudo curl linux-base dialog crda \
		wireless-regdb ncurses-term python3-apt sysfsutils toilet u-boot-tools unattended-upgrades \
		usbutils wireless-tools console-setup unicode-data openssh-server initramfs-tools \
		ca-certificates resolvconf expect rcconf iptables mc abootimg man-db wget

	apt-get -y clean
	apt-get -y autoclean

	# Non-essential packages
	apt-get install -y alsa-utils btrfs-tools dosfstools hddtemp iotop stress sysbench screen ntfs-3g vim pciutils \
		evtest htop pv lsof apt-transport-https libfuse2 libdigest-sha-perl libproc-processtable-perl aptitude dnsutils f3 haveged \
		hdparm rfkill vlan sysstat bash-completion hostapd git ethtool network-manager unzip ifenslave command-not-found lirc \
		libpam-systemd iperf3 software-properties-common libnss-myhostname f2fs-tools avahi-autoipd iputils-arping

	apt-get -y clean
	apt-get -y autoclean

	# Desktop
	apt-get install -y xserver-xorg xserver-xorg-video-fbdev gvfs-backends gvfs-fuse xfonts-base xinit x11-xserver-utils xterm thunar-volman \
		gksu bluetooth network-manager-gnome network-manager-openvpn-gnome gnome-keyring gcr libgck-1-0 libgcr-3-common p11-kit pasystray pavucontrol pulseaudio \
		paman pavumeter pulseaudio-module-gconf bluez bluez-tools pulseaudio-module-bluetooth blueman libgl1-mesa-dri gparted synaptic \
		policykit-1 mesa-utils

	apt-get -y clean
	apt-get -y autoclean

	# Office
	apt-get install -y lxtask mirage galculator hexchat mpv \
		gtk2-engines gtk2-engines-murrine gtk2-engines-pixbuf libgtk2.0-bin gcj-jre-headless libgnome2-perl \
		network-manager-gnome network-manager-openvpn-gnome gnome-keyring gcr libgck-1-0 libgcr-3-common p11-kit pasystray pavucontrol pulseaudio \
		libpam-gnome-keyring thunderbird system-config-printer-common numix-gtk-theme paprefs tango-icon-theme \
		libreoffice-writer libreoffice-style-tango libreoffice-gtk fbi cups-pk-helper cups

	apt-get -y clean
	apt-get -y autoclean

	# lightdm
	apt-get install -y lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings

	# Mate
	apt-get install -y mate-desktop-environment-extras mate-media mate-screensaver mate-utils mate-power-manager mate-applets ubuntu-mate-lightdm-theme mozo \
		nano linux-firmware zram-config chromium-browser gnome-icon-theme-full language-selector-gnome system-config-printer-gnome

	## Gnome-player
	apt -y  $APT_OPTIONS install gnome-mplayer
fi

apt-get -y clean
apt-get -y autoclean

if [ "$LINUX" == "mainline" ] && [ "$UBUNTU_ARCH" == "arm64" ]; then

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

if [ "$KHADAS_BOARD" == "VIM" ] && [ "$LINUX" == "3.14" ]; then
	# Install amremote
	if [ -f /pkg-aml-amremote_${UBUNTU_ARCH}.deb ]; then
		dpkg -i /pkg-aml-amremote_${UBUNTU_ARCH}.deb
		rm -rf /pkg-aml-amremote_${UBUNTU_ARCH}.deb

		# Enable khadas remote
		cp /boot/remote.conf.vim /boot/remote.conf

		systemctl --no-reload enable amlogic-remotecfg.service
	fi

	# Install mali
	if [ -f /pkg-aml-mali_${UBUNTU_ARCH}.deb ]; then
		dpkg -i /pkg-aml-mali_${UBUNTU_ARCH}.deb
		rm -rf /pkg-aml-mali_${UBUNTU_ARCH}.deb
	fi

	# Install kodi
	if [ -f /pkg-aml-kodi_${UBUNTU_ARCH}.deb ]; then
		dpkg -i /pkg-aml-kodi_${UBUNTU_ARCH}.deb
		rm -rf /pkg-aml-kodi_${UBUNTU_ARCH}.deb
	fi

	usermod -a -G audio,video,disk,input,tty,root,users,games khadas
fi

cd /

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

if [ "$LINUX" == "3.14" ]; then
	echo dwc3 >> /etc/modules
	echo dwc_otg >> /etc/modules
fi

# Load mali module
echo mali >> /etc/modules

# Load WIFI at boot time(MUST HERE)
echo dhd >> /etc/modules

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
apt-get -y clean
apt-get -y autoclean
#history -c

# Self-deleting
rm $0
