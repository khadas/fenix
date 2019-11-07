#!/bin/bash

DAEMON=/usr/local/bin/iv009_isp

. /etc/fenix-release

if [ "$BOARD" != "VIM3" ]; then
	echo "$BOARD does not support ISP!"
	exit
fi

$DAEMON

exit 0
