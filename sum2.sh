#/bin/bash
#
let SUM=0
let i=0

while [ $i -lt 100 ];do
	let i++
	if [ $[$i%2] -eq 0 ]; then
		continue
	fi
	let SUM+=$i
done

echo $SUM 
