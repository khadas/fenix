#!/bin/bash

case $1 in
start)
	echo "Starting rkaiq_3A_server ..."
	/usr/bin/rkaiq_3A_server 2>&1 | logger -t rkaiq &
	;;
stop)
	pkill rkaiq_3A_server
	echo "Kill and stop rkaiq_3A_server ..."
	;;
*)
	echo "Do nothing ..."
	;;
esac
