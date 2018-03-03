#/bin/bash
#

until bash -n $1 &> /dev/null ; do
  read -p 'Syntax error,[Qq] to quit,other for editing:' CHOICE
  case $CHOICE in q|Q)
        echo "Something wrong,quiting..."
    	exit 5
     	 ;;
    *)
     	vim + $1
	;;
    esac
done
