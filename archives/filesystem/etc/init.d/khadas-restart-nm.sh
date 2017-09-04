#! /bin/sh
### BEGIN INIT INFO
# Provides:          khadas-restart-nm
# Required-Start:    
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: Run /etc/init.d/network-manager restart
### END INIT INFO

PATH=/sbin:/usr/sbin:/bin:/usr/bin

do_start() {
	/etc/init.d/network-manager restart
}

case "$1" in
	start)
		do_start
		;;
	restart|reload|force-reload)
		echo "Error: argument '$1' not supported" >&2
		exit 3
		;;
	stop|status)
		# No-op
		exit 0
		;;
	*)
		echo "Usage: $0 start|stop" >&2
		exit 3
		;;
esac

