#/bin/bash
#

PING() {
for i in {1..10}; do
	if ping  -c1 -w1 172.21.0.$i &> /dev/null; then
		echo "172.21.0.$i  is up"
	else
		echo "172.21.0.$i is down"	
	fi
done	
}

PING2() {
if ping  -c1 -w1 $1  &> /dev/null; then
	return 0	
else
	return 1
fi
}

#PING

#PING2 $1

for i in {1..20}; do
	if PING2 172.21.3.$i; then
		echo "172.21.3.$i is up"
	else
		echo "172.21.3.$i is down" 
	fi
done 
