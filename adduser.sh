#/bin/bash
#
if ! id -u $1 &> /dev/null ; then 
	useradd $1
	echo $1 | passwd --stdin $1 &> /dev/null
fi
 

