#!/bin/bash
export file_path='/root/helm-chart/'
#echo $file_path
export  folder=`ls $file_path`
#echo $folder
defaultMirror="docker.m.daocloud.io"
export mirrorArray=(
quay.io
docker.io
ghcr.io
gcr.io
k8s.gcr.io
registry.k8s.io
quay.io
)

for Chart in $folder; do
        #imgs=`helm template  "$file_path$Chart" 2> /dev/null  |grep "image:" | sed -e 's/^[ ]*//g'  | sort -n | uniq | sed -e 's/\"//g'`
        for i in $(helm template  "$file_path$Chart" 2> /dev/null  |grep "image:" | sed -e 's/^[ ]*//g' | sed -e 's/[ ]*$//g' -e 's/"//g' -e 's/\s-//g'| sort -u | uniq ); do
                if  [[ "$i" =~ "image".* ]]; then
                        continue
                else
#                       echo $i
                        imgtagPrefix=${i%%/*}
                        if [[  "${mirrorArray[@]}" =~ $imgtagPrefix ]]; then
                                tmp=${i#*/}
                                mirrorPrefix=${imgtagPrefix%.*}
                                mirrorEnd=${imgtagPrefix##*.}
                                daocloudMirror="${imgtagPrefix%.*}.m.daocloud.$mirrorEnd"
#                               echo $daocloudMirror
                                i="$daocloudMirror/$tmp"
#                               echo $i
                        elif [[ "$imgtagPrefix" =~ ^[a-zA-Z][-a-zA-Z0-9]{0,62}([a-zA-Z0-9][-a-zA-Z0-9]{0,62})+$ ]]; then
                                i="$imgtagPrefix/$i"
                        fi
                        imgName=${i##*/}
                        imgVer=${imgName##*:}
                        imgCom=${imgName%%:*}
#                       echo $imgVer
#                       echo $imgCom
                        docker pull $i 
                        docker save -o  "$file_path$imgCom-$imgVer.tar" $i

                fi

        done
#echo $folder
done
