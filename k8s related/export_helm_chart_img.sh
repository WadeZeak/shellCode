#!/bin/bash

###helm chart所在目录
export file_path="/root/dce5_components/helm_chart"
#echo $file_path
export download_path="/root/dce5_components/chart_image"

### 获取目录下文件列表
export  folder=`find $file_path -type f | grep -E '*.tgz$'`
echo -e "helm chart list:\n $folder"
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

for Chart in ${folder[@]}; do
        #imgs=`helm template  "$file_path$Chart" 2> /dev/null  |grep "image:" | sed -e 's/^[ ]*//g'  | sort -n | uniq | sed -e 's/\"//g'`
        ## imgae: Register/Registry/ImgName:Version
        img_list_tmp=$(helm template  "$Chart" 2> /dev/null  |grep "image:" | sed -e 's/^[ ]*//g' | sed -e 's/[ ]*$//g' -e "s/[\'\"]//g" -e 's/\s-//g' -e 's/^-//g' -e 's/^#//g'|sed -e 's/^[ ]*//g' | sort -u | uniq )
        img_list=$(echo "$img_list_tmp" | awk '{print $2}')
        
        echo -e "\n\n\n\n#############download $Chart imgages###################\n"
        echo -e "image list:\n $img_list\n\n\n\n"
        ### 从helm template生成的yaml中 获取 Chart所需的img
        for i in ${img_list[@]}; do
#                       echo $i
                        ## 获取镜像name
                        imgName=${i##*/}
                         
                        ## 获取镜像version
                        imgVer=${i##*:}

                        ###判断镜像是否有prefix
                        if [[ `echo $i| grep "/"`   ]]; then
                 
                        ### 获取镜像Tag前缀                    
                          imgtagPrefix=${i%%/*}
#                          echo "imgtagPrefix = $imgtagPrefix"
                          ### 将原有镜像源x.y.z替换为 加速镜像源 x.y.m.daocloud.z
                          if [[  "${mirrorArray[@]}" =~ $imgtagPrefix ]]; then
                                tmp=${i#*/}
                                mirrorPrefix=${imgtagPrefix%.*}
                                mirrorEnd=${imgtagPrefix##*.}
                                daocloudMirror="${imgtagPrefix%.*}.m.daocloud.$mirrorEnd"
#                               echo $daocloudMirror
                                i="$daocloudMirror/$tmp"
                          ### 若镜像tag前缀是字符串，不是域名格式，则使用默认docker加速镜像源
                          elif [[ "$imgtagPrefix" =~ ^[a-zA-Z][-a-zA-Z0-9]{0,62}([a-zA-Z0-9][-a-zA-Z0-9]{0,62})+$ ]]; then
                            ###镜像tag是否有Version
                            if [[ $imgVer == $i ]]; then
                                imgVer="latest"
                                i="$defaultMirror/$i:$imgVer"
                            ###  镜像tag有Version   
                            else
                                i="$defaultMirror/$i"
                            fi       
                          fi         
                        ### 镜像tag没有Regiry url
                        else
                          ###镜像tag是否有Version
                          if [[  $imgVer == $i ]]; then
                                imgVer="latest"
                                i="$defaultMirror/$i:$imgVer"
                          else
                                i="$defaultMirror/$i"    

                          fi
                        fi
                        
                        imgCom=${imgName%%:*}
#                       echo $imgVer
#                        echo $imgCom
                        echo -e "pull  image:  $i"
                        docker pull $i 
                        ### 导出的镜像名字为 软件名称-版本.tar
                        echo -e "\nsave image: $download_path/$imgCom-$imgVer.tar\n"
                        docker save -o  "$download_path/$imgCom-$imgVer.tar" $i
        done
#echo $folder
done
