#/bin/bash
#
REPOFILE=/etc/yum.repos.d/$1

if [ -e $REPOFILE ]; then
	echo "$1 exists"
	exit  3
fi

read -p "Repository ID:" REPOID
until [ $REPOID == 'quit' ]; do
	echo "[$REPOID]" >> $REPOFILE
	read -p "Repository name:" REPONAME
	echo "name=$REPONAME" >> $REPOFILE
	read -p "Repository Baseurl:" REPOURL
	echo "baseurl=$REPOURL" >> $REPOFILE
	echo -e 'enable=1\ngpcheck=0' >> $REPOFILE
	read -p "Repository ID:" REPOID
done

