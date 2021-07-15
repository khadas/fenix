#!/bin/bash

## reboot test

[ "$REBOOT_DELAY" ] || \
    REBOOT_DELAY=30

grep -q reboot_test /proc/cmdline || exit 0

sleep 1
echo "[$(date)] REBOOT test after $REBOOT_DELAY sec" | tee /dev/kmsg > /dev/console
sleep $REBOOT_DELAY

sync
reboot -f reboot_test
