#!/bin/sh -x

# Try to figure out XAUTHORITY and DISPLAY
for pid in $(pgrep X 2>/dev/null || ls /proc|grep -ow "[0-9]*"|sort -rn); do
    PROC_DIR=/proc/$pid

    # Filter out non-X processes
    readlink $PROC_DIR/exe|grep -qwE "X$|Xorg$" || continue

    # Parse auth file and display from cmd args
    export XAUTHORITY=$(cat $PROC_DIR/cmdline|tr '\0' '\n'| \
        grep -w "\-auth" -A 1|tail -1)
    export DISPLAY=$(cat $PROC_DIR/cmdline|tr '\0' '\n'| \
        grep -w "^:.*" || echo ":0")

    echo Found auth: $XAUTHORITY for dpy: $DISPLAY
    break
done

export DISPLAY=${DISPLAY:-:0}

# Find an authorized user
unset USER
for user in root $(users);do
    sudo -u $user xdpyinfo &>/dev/null && \
        { USER=$user; break; }
done
[ $USER ] || exit 0

# Find connected monitors
MONITORS=$(sudo -u $user xrandr|grep -w connected|cut -d' ' -f1)

# Make sure every connected monitors been enabled with a valid mode.
for monitor in $MONITORS;do
    # Unlike the drm driver, X11 modesetting drv uses HDMI for HDMI-A
    CRTC=$(echo $monitor|sed "s/HDMI\(-[^B]\)/HDMI-A\1/")

    SYS="/sys/class/drm/card*-$CRTC/"

    # Already got a valid mode
    grep -w "$(cat $SYS/mode)" $SYS/modes && continue

    # Ether disabled or wrongly configured
    sudo -u $user xrandr --output $monitor --auto
done

exit 0
