#/bin/bash
#

read -p "Pleas input something:"  STRING
until [ $STRING == 'quit' ]; do 
	echo $STRING | tr 'a-z' 'A-Z'
	read -p "Please input something again:" STRING	
done


