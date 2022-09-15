#!/bin/bash

###helm chart所在目录
export file_path='/root/helm-chart/'
#echo $file_path

### 获取目录下文件列表
export  folder=`ls $file_path`
#echo $folder
#默认镜像源 docker.io
defaultMirror="docker.m.daocloud.io"

### 可加速的镜像源列表 支持列表参考https://github.com/DaoCloud/public-image-mirror
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
        ### 从helm template生成的yaml中 获取 Chart所需的img
        for i in $(helm template  "$file_path$Chart" 2> /dev/null  |grep "image:" | sed -e 's/^[ ]*//g' | sed -e 's/[ ]*$//g' -e 's/"//g' -e 's/\s-//g'| sort -u | uniq ); do
                if  [[ "$i" =~ "image".* ]]; then
                        continue
                else
#                       echo $i
                        ### 获取镜像Tag前缀                    
                        imgtagPrefix=${i%%/*}
                        ### 将原有镜像源x.y.z替换为 加速镜像源 x.y.m.daocloud.z
                        if [[  "${mirrorArray[@]}" =~ $imgtagPrefix ]]; then
                                tmp=${i#*/}
                                mirrorPrefix=${imgtagPrefix%.*}
                                mirrorEnd=${imgtagPrefix##*.}
                                daocloudMirror="${imgtagPrefix%.*}.m.daocloud.$mirrorEnd"
#                               echo $daocloudMirror
                                i="$daocloudMirror/$tmp"
#                               echo $i
                        ### 若镜像tag前缀是字符串，不是域名格式，则使用默认docker加速镜像源
                        elif [[ "$imgtagPrefix" =~ ^[a-zA-Z][-a-zA-Z0-9]{0,62}([a-zA-Z0-9][-a-zA-Z0-9]{0,62})+$ ]]; then
                                i="$imgtagPrefix/$i"
                        fi
                        imgName=${i##*/}
                        imgVer=${imgName##*:}
                        imgCom=${imgName%%:*}
#                       echo $imgVer
#                       echo $imgCom
                        docker pull $i 
                        ### 导出的镜像名字为 软件名称-版本.tar
                        docker save -o  "$file_path$imgCom-$imgVer.tar" $i

                fi

        done
#echo $folder
done
