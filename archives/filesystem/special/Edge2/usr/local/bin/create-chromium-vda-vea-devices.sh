#!/bin/bash

cat <<EOF >/dev/video-dec0
type=dec
codecs=VP8:VP9:H.264:H.265:AV1
max-width=7680
max-height=4320
EOF

echo enc > /dev/video-enc0

chown root:video /dev/video-dec0 /dev/video-enc0
chmod 0660 /dev/video-dec0 /dev/video-enc0


