#/bin/sh
#

who | grep "hadoop" &> /dev/null
RETVAL=$?

until [ $RETVAL -eq 0 ]; do
	echo "hadoop not yet lande"
	sleep 5
	who | grep "hadoop" &> /dev/null

done

echo "hadoop is logged on."
