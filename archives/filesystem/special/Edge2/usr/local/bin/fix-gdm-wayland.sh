#!/bin/bash

[ -f /sys/class/drm/card0-DSI-1/modes ] && exit 0

if systemctl is-active --quiet gdm && grep -Fxq "WaylandEnable=true" /etc/gdm3/custom.conf; then
	if [ ! -f /tmp/.gdm-wayland-fix ]; then
		sleep 5
		pidof gdm-x-session > /dev/null && systemctl restart gdm && touch /tmp/.gdm-wayland-fix
	fi
fi

exit 0
