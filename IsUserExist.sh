#/bin/bash
#

USER() {
if id $1 &> /dev/null ; then 
	echo "`grep ^$1 /etc/passwd | cut -d: -f3,7`"
	return 0
else 
	echo "NO $1"
	return 1
fi
}

read -p "please input a username:" USERNAME	
until [ $USERNAME == 'q' -o $USERNAME == 'Q' ]; do
	USER $USERNAME
	if [ $? == 0 ]; then 
		read -p "please input again:" USERNAME
	else 
		read -p "NO $USERNAME,please inlut a correct username:" USERNAME
	fi
	
done 
