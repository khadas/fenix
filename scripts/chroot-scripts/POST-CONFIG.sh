#!/bin/bash

## hyphop ##+

#= post config chroot script

case $(readlink /proc/self/cwd) in
	*fenix*) echo "[e] only for chroot usage">&2 ; exit 1 ;;
esac

#set -e -o pipefail

export LC_ALL=C
export LANG=C

# Default user name, password and hostname

    DEFAULT_USER_NAME=khadas
DEFAULT_USER_PASSWORD=khadas
DEFAULT_ROOT_PASSWORD=khadas
#   DEFAULT_HOST_NAME=khadas

        DEFAULT_SHELL=/bin/bash

## rewrite

[ "$USER_SHELL" ] || \
	USER_SHELL=$DEFAULT_SHELL

[ "$USER_NAME" ] || \
	USER_NAME=$DEFAULT_USER_NAME

[ "$USER_NAME" = "$DEFAULT_USER_NAME" ] || \
	DEFAULT_USER_PASSWORD=

[ "$USER_PASSWORD" ] || \
	USER_PASSWORD=$DEFAULT_USER_PASSWORD

[ -z ${ROOT_PASSWORD+x} ] && \
	ROOT_PASSWORD=$DEFAULT_ROOT_PASSWORD

[ "$ROOT_PASSWORD" = "-" ] && \
	ROOT_PASSWORD=

[ "$HOST_NAME" ] || \
	HOST_NAME=$USER_NAME

#USER_PASSWORD_ENCRYPTED=

# Setup password for root user

for KERNEL_ in $KERNEL_ $(ls /boot/*z-*); do
	[ -e $KERNEL_ ] || {
	echo "[e] $0 KERNEL not found $KERNEL_">&2
	exit 1
	}
	KERNEL_VER=${KERNEL_#*-}
	KERNEL_LNK=/boot/zImage
	KERNEL_IMG=vmlinuz-$KERNEL_VER
	[ -e $KERNEL_LNK ] || {
	echo "[i] kernel link not exist $KERNEL_IMG => $KERNEL_LNK"
	ln -s $KERNEL_IMG $KERNEL_LNK
	}
	[ -e /boot/initrd.img ] && {
	VER=$(readlink /boot/initrd.img)
	echo "[i] initrd already exist $VER"
	break
	}
	echo update-initramfs -u -k $KERNEL_VER
	update-initramfs -u -k $KERNEL_VER -v
	break
done

# Setup password for root user

if [ "$ROOT_PASSWORD_ENCRYPTED" ]; then
	ROOT_PASSW='******'
	echo root:$ROOT_PASSWORD_ENCRYPTED | chpasswd -e
elif [ "$ROOT_PASSWORD" ]; then
	ROOT_PASSW=${ROOT_PASSWORD//?/\*}
	echo root:$ROOT_PASSWORD | chpasswd
else
	echo "[i] ROOT empty password"
	ROOT_PASSW="__EMPTY__"
	passwd -d root
fi

# user

[ "$PASSW_CRYPT_ARGS" ] || \
	PASSW_CRYPT_ARGS="-5" # SHA256-based password algorithm

if [ "$USER_PASSWORD" -o "$USER_PASSWORD_ENCRYPTED" ]; then
	if [ "$USER_PASSWORD_ENCRYPTED" ]; then
	USER_PASSW_ENC_="USER_PASSWORD_ENCRYPTED: $USER_PASSWORD_ENCRYPTED"
	else
	# openssl help passwd # read more about this
	USER_PASSWORD_ENCRYPTED=$(echo -n "$USER_PASSWORD"|openssl passwd $PASSW_CRYPT_ARGS -stdin)
	fi
	useradd -m -p "$USER_PASSWORD_ENCRYPTED" -s $USER_SHELL $USER_NAME
	USER_PASSW=${USER_PASSWORD//?/\*}
else
	useradd -m -s $USER_SHELL $USER_NAME
	echo "[i] USER ($USER_NAME) empty password"
	USER_PASSW="__EMPTY__"
	passwd -d $USER_NAME
fi

# need to check it // for allow login without password
# have it for debian buster !
#
# cat /etc/pam.d/common-auth
#-auth	[success=1 default=ignore]	pam_unix.so nullok_secure
#+auth	[success=1 default=ignore]	pam_unix.so nullok
#
s=/etc/pam.d/common-auth
grep -H -m1 nullok_secure $s && \
	sed -i s/nullok_secure/nullok/ $s && \
		grep -m1 nullok $s

for s in ttyAML0 ttyFIQ0 ; do
echo $s >> /etc/securetty
done

usermod -aG sudo,adm $USER_NAME

echo "
=====================================
HOST_NAME: $HOST_NAME
-------------------------------------
ROOT_PASSWORD: $ROOT_PASSW
USER_NAME: $USER_NAME
USER_PASSWORD: $USER_PASSW
$USER_PASSW_ENC_
=====================================
"

## install custom ssh keys
for k in $SSH_PUBS; do
	#user:key
	user=${k%%:*}
	key=${k#*:}
	key=${key//!/ }
	echo "[i] ssh add key $user : $key"

	case $user in
	-|"")
	users="root $USER_NAME"
	;;
	*)
	users=$user
	;;
	esac

	for user in $users; do
	case $user in
	root)
	H="/root/.ssh"
	;;
	*)
	H="/home/$user/.ssh"
	esac
	echo "[i] ssh add key $user => $H"
	mkdir -p -m700 $H
	echo "$key" >> $H/authorized_keys
	chown $user: -R $H
	chmod 0600 $H/authorized_keys
	done
done

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

echo "Add $USER_NAME to ($DEFGROUPS) groups."
usermod -a -G $DEFGROUPS $USER_NAME

# Setup host
echo $HOST_NAME > /etc/hostname
# add hostname to hosts
cat <<-EOF >> /etc/hosts
127.0.0.1   $HOST_NAME
::1         $HOST_NAME
EOF

cd /

# Build time
LC_ALL="C" date > /etc/fenix-build-time

if [ "$POST_CMD" ]; then
echo "POST_CMD: $POST_CMD"
$POST_CMD
fi
