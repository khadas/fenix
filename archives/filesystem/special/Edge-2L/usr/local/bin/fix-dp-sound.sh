#!/bin/bash

if ! pacmd list-sinks | grep platform-dp0-sound > /dev/null; then
	systemctl --user restart pulseaudio.service
fi

exit
