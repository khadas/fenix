#!/bin/sh

#quectel-pppd devname apn user password
echo "quectel-pppd options in effect:"
QL_DEVNAME=/dev/ttyUSB3
QL_APN=3gnet
QL_USER=user
QL_PASSWORD=passwd
if [ $# -ge 1 ]; then
	QL_DEVNAME=$1
	echo "devname   $QL_DEVNAME    # (from command line)"
else
	echo "devname   $QL_DEVNAME    # (default)"
fi
if [ $# -ge 2 ]; then
	QL_APN=$2
	echo "apn       $QL_APN    # (from command line)"
else
	echo "apn       $QL_APN    # (default)"
fi
if [ $# -ge 3 ]; then
	QL_USER=$3
	echo "user      $QL_USER   # (from command line)"
else
	echo "user      $QL_USER   # (default)"
fi
if [ $# -ge 4 ]; then
	QL_PASSWORD=$4
	echo "password  $QL_PASSWORD   # (from command line)"
else
	echo "password  $QL_PASSWORD   # (default)"
fi

CONNECT="'chat -s -v ABORT BUSY ABORT \"NO CARRIER\" ABORT \"NO DIALTONE\" ABORT ERROR ABORT \"NO ANSWER\" TIMEOUT 30 \
\"\" AT OK ATE0 OK ATI\;+CSUB\;+CSQ\;+CPIN?\;+COPS?\;+CGREG?\;\&D2 \
OK AT+CGDCONT=1,\\\"IP\\\",\\\"$QL_APN\\\",,0,0 OK ATD*99# CONNECT'"

pppd $QL_DEVNAME 115200 user "$QL_USER" password "$QL_PASSWORD" \
connect "'$CONNECT'" \
disconnect 'chat -s -v ABORT ERROR ABORT "NO DIALTONE" SAY "\nSending break to the modem\n" "" +++ "" +++ "" +++ SAY "\nGood bay\n"' \
noauth debug defaultroute noipdefault novj novjccomp noccp ipcp-accept-local ipcp-accept-remote ipcp-max-configure 30 local lock modem dump nodetach nocrtscts usepeerdns &
