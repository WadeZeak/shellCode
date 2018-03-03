#/bin/bash
#

declare -i  offNum=0
declare -i onNum=0
for ((i=1;i<5;i++)); do
	ping -c 2 -W  2 192.168.100.$i &> /dev/null && ( let onNum+=1 ; echo "192.168.100.$i is online" ) || (let offNum+=1 ;echo "192.168.100.$i is offline" )
done


echo "the num of offline host is $offNum"
echo "the num of online host is $onNum"
 





