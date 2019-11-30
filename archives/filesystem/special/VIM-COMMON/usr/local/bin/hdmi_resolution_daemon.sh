#!/bin/bash

PIPE="/tmp/hdmi_resolution_pipe"
HDMI_HANDLER="/usr/local/bin/hdmi.sh"

# Create a pipe for communcation with clients
if [[ ! -p "${PIPE}" ]]; then
	mkfifo "${PIPE}"
fi

chmod 777 ${PIPE}

check_resolution() {
	resolution="$1"

	case $resolution in
		*p60hz)
			return 0
			;;
		*)
			return -1
			;;
	esac
}

hdmi_resolution_handler() {

	resolution=`echo $1 | awk -F "_" '{print $3}'`

	if ! check_resolution $resolution; then
		return -1
	fi

	sudo systemctl stop lightdm.service
	$HDMI_HANDLER $resolution
	sudo systemctl start lightdm.service
}

while true
do
	if read EVENT <> "${PIPE}"; then
		case $EVENT in
			change_resolution_*)
				hdmi_resolution_handler $EVENT
				;;
		esac
	fi
done
