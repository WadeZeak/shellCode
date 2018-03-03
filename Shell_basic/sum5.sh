#/bin/bash
#
SUM() {
 echo $[$1+$2]
}

for i in {1..10}; do
	let j=$[$i+1]
	 SUM $i $j
done
