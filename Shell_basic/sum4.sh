#/bin/bash
#

TWOSUM() {
A=1
B=2
C=$[$A+$B]
echo $C
}

D=11
SUM=$[`TWOSUM` + $D ]
echo $SUM

echo $?
