#!/bin/bash

if [ "$1" == "remove" ]; then
	if [ -f /sys/devices/platform/display-subsystem/drm/card0/card0-DP-1/status ]; then
		STATUS=$(cat /sys/devices/platform/display-subsystem/drm/card0/card0-DP-1/status)
		if [ "$STATUS" == "connected" ]; then
			echo off > /sys/devices/platform/display-subsystem/drm/card0/card0-DP-1/status
		fi
	fi
elif [ "$1" == "add" ]; then
	if [ -f /sys/devices/platform/display-subsystem/drm/card0/card0-DP-1/status ]; then
		STATUS=$(cat /sys/devices/platform/display-subsystem/drm/card0/card0-DP-1/status)
		if [ "$STATUS" == "disconnected" ]; then
			echo on > /sys/devices/platform/display-subsystem/drm/card0/card0-DP-1/status
			sleep 0.5
			echo off > /sys/devices/platform/display-subsystem/drm/card0/card0-DP-1/status
			sleep 1
			echo on > /sys/devices/platform/display-subsystem/drm/card0/card0-DP-1/status
		fi
	fi
fi

exit
