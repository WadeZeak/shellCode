#/bin/bash
#
LOCKFILE=/var/lock/subsys/service

Status() {
	if [ -e $LOCKFILE ]; then
		echo "Running..."
	else 
		echo "Stop..."
	fi
}

Usage() {
	echo "`basename $0` {start|stop|restart|status}"
}

case $1 in
start)
	echo "Starting...."
	touch $LOCKFILE ;;
stop)
	echo "Stop..."
	rm -f $LOCKFILE &> /dev/null ;;
restart)
	echo "Restarting..." ;;
status)
	Status ;;
*)
	Usage ;;
esac


 
