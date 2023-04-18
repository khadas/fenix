#!/bin/bash

if systemctl is-active --quiet gdm && grep -Fxq "WaylandEnable=true" /etc/gdm3/custom.conf; then
	if [ ! -f /tmp/.gdm-wayland-fix-hotplug ]; then
		pidof gdm-x-session > /dev/null && systemctl restart gdm && touch /tmp/.gdm-wayland-fix-hotplug
	fi
fi

exit 0
