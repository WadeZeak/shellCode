#/bin/bash
#
if [ $1 == '-s' ]; then
elif [ $1 == '--help' ]; then
	echo "Usage:`basename $0`:w -s shell | --help"
	exit 0 
else 
	echo "Unknow Options."
	exit 8

NUMOFUSER=`grep "${2}$" /etc/passwd | wc -l`
SHELLUSERS=`grep "${2}$" /etc/passwd | cur -d: -fl`
SHELLUSERS=`echo $SHELLUSERS | sed 's@[[:space:]]@,@g'`

echo -e "$2,$NUMOFUSER users,they are: \n$SHELLUSERS"
