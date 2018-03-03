#/bin/bash
#
while :; do
  read -p "please a path of file:" FILEPATH
  if [ -e FILEPATH ]; then
	echo "$FILEPATH exists."
  else
	echo "NO $FILEPATH."
  fi
done

echo "QUIT"
