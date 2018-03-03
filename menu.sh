#/bin/bash
#

#dispaly menu
cat << EOF
d|D) show disk usages
m|M) show memory usages
s|S) show swap usages
q|Q) quit
EOF

read -p "pease input your choice:" CHOICE

until [ $CHOICE == 'q' -o $CHOICE == 'Q' ]; do
case $CHOICE in 
d|D)	df -lh ;;
m|M)	free -m | grep "^Mem" ;;
s|S)	free -m | grep "^Swap" ;;
q|Q) 	exit 0 ;;
esac
read -p "please input your choice:" CHOICE
done

