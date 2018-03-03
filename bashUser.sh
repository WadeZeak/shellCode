#/bin/bash
#
FILE=/etc/passwd
let i=1
while read LINE;do
  [ `echo $LINE | awk -F : '{print $3}'` -le 500 ] && continue
  [ `echo $LINE | awk -F : '{print $7}'` == '/bin/bash' ] && echo $LINE | awk -F : '{print $1}' && let i++ && 
  [ $i -gt 2 ] && break 
done < $FILE

