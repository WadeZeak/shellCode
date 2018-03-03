#/bin/bash
#
:<<!
#declare -i SUM=0

#for i in {1..100}; do
	let SUM+=$i
#done

#echo $SUM
!
declare -i SUM=0
for ((i=1;i<=100;i++)); do
	let SUM+=i
done

echo $SUM


