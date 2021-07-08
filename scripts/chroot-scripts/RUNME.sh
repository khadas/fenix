#!/bin/bash

#set -e -o pipefail

case $(readlink /proc/self/cwd) in
    *fenix*)
    echo "[e] only for chroot usage">&2
    exit 1
    ;;
esac

export LC_ALL=C
export LANG=C

# Default user name, password and hostname
USERNAME=khadas
USER_PASSWORD=khadas
ROOT_PASSWORD=khadas
HOSTNAME=Khadas

# Setup password for root user
echo root:$ROOT_PASSWORD | chpasswd

# Admin user
USER_PASSWORD_ENCRYPTED=`perl -e 'printf("%s\n", crypt($ARGV[0], "password"))' "$USER_PASSWORD"`
useradd -m -p "$USER_PASSWORD_ENCRYPTED" -s /bin/bash $USERNAME
usermod -aG sudo,adm $USERNAME

# Clean ssh keys
rm -f /etc/ssh/ssh_host*

# Add group
DEFGROUPS="audio,video,disk,input,tty,root,users,games,dialout,cdrom,dip,plugdev,bluetooth,pulse-access,systemd-journal,netdev,staff,i2c"
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

echo "Add $USERNAME to ($DEFGROUPS) groups."
usermod -a -G $DEFGROUPS $USERNAME

# Setup host
echo $HOSTNAME > /etc/hostname
# set hostname in hosts file
cat <<-EOF > /etc/hosts
127.0.0.1   localhost $HOSTNAME
::1         localhost $HOSTNAME ip6-localhost ip6-loopback
fe00::0     ip6-localnet
ff00::0     ip6-mcastprefix
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EOF

cd /

# Build time
LC_ALL="C" date > /etc/fenix-build-time
sync

# Clean up
apt-get update
apt-get -y clean
apt-get -y autoclean
#history -c

# Self-deleting
rm $0
