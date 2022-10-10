#!/bin/bash

### 镜像文件所在目录
export file_path='/root/offline/'

### 搜索.tar结尾的镜像文件
##export imgs_folder=`find $file_path -name  "*.tar"`
export imgs_folder=`find $file_path -type f | grep -E '*.tar$'`

### 目标仓库地址前缀
export destRegistry="10.120.0.31:30880/daocloud"

for offline_imgs in $imgs_folder ; do
        Output=`docker load -i $offline_imgs`
        ### 过滤镜像tag
        imgTagOri=${Output##* }
#       OriMirror=$(echo  $imgTagOri | awk -F'/' '{print $1}')
#       echo $imgTagOri
#       echo $OriMirror 
        ### 获取镜像tag前缀
        imgTagPrefix=$(echo  $imgTagOri | awk -F'/' '{print $1}')
        
        ### 判断镜像tag 前缀是否是域名格式
        if [[ "$imgTagPrefix" =~ ^[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+ ]]; then
#               echo  $imgTagPrefix
                ### 替换镜像前缀为 目标仓库地址（前缀）
                img=$(echo $imgTagOri | sed "s@$imgTagPrefix@$destRegistry@g")
        else
                img="$destRegistry/$imgTagOri"
        fi
#        echo $img
        docker tag $imgTagOri $img
        docker push $img
done
