#/bin/bash
#
declare -i SUM=0

for i in {1..1000}; do
  let SUM+=i
  if [ $SUM -gt 5000 ]; then
    break
  fi
  echo $SUM
done

