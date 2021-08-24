#!/bin/sh
## hyphop ##

#= merger alsa state files

cd $(dirname "$0")
echo merge: asound.*.state to asound.state
pwd
cat asound.*.state > asound.state
