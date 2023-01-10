#!/bin/bash

###helm chart所在目录
file_path="./addon"
#echo $file_path
download_path="./chart_image"

if [ ! -d $download_path ]; then
        mkdir -p $download_path
fi

### 获取目录下文件列表
helm_chart_file_list=`find $file_path -type f | grep -E '*.tgz$'`
echo -e "Helm Chart List:\n $helm_chart_file_list\n\n\n"
#默认镜像源 docker.io
defaultMirror="docker.m.daocloud.io"

### 可加速的镜像源列表 支持列表参考https://github.com/DaoCloud/public-image-mirror
universalMirrorArray=(
quay.io
docker.io
ghcr.io
gcr.io
#k8s.gcr.io
#registry.k8s.io
quay.io
nvcr.io
)

###其他可加速的镜像源列表
specialMirrorArray=(
cr.l5d.io
docker.elastic.co
k8s.gcr.io
registry.k8s.io
mcr.microsoft.com
registry.jujucharms.com
rocks.canonical.com
)


PULLED_IMAGES_HELM_CHART_LIST=PULLED_IMAGES_HELM_CHART_LIST
WITHOUT_PULLING_IMAGES_HELM_CHART_LIST=WITHOUT_PULLING_IMAGES_HELM_CHART_LIST

if [ -f $file_path/$PULLED_IMAGES_HELM_CHART_LIST ]; then
        pulled_images_helm_chart_list=$(cat $file_path/$PULLED_IMAGES_HELM_CHART_LIST)
#       echo -e "\n\n pulled_images_helm_chart_list is \n\n$pulled_images_helm_chart_list"
        if [  -n "$pulled_images_helm_chart_list" ]; then
                echo -e "The helm chart that has pulled the image:\n$pulled_images_helm_chart_list\n\n\n"
        fi
else
        touch $file_path/$PULLED_IMAGES_HELM_CHART_LIST
fi


if  [ -f $file_path/$WITHOUT_PULLING_IMAGES_HELM_CHART_LIST  ]; then
        without_pulling_images_helm_chart_list=$(cat $file_path/$WITHOUT_PULLING_IMAGES_HELM_CHART_LIST)
#       echo -e "\n\nwithout_pulling_images_helm_chart_list is \n$without_pulling_images_helm_chart_list"
        if [  -n "$without_pulling_images_helm_chart_list" ]; then
                echo -e " The helm chart without pulling the image:\n$without_pulling_images_helm_chart_list\n\n\n"
                helm_chart_file_list=$without_pulling_images_helm_chart_list
        fi
else
        echo -e  "$helm_chart_file_list" > $file_path/$WITHOUT_PULLING_IMAGES_HELM_CHART_LIST
fi


PULLED_IMAGE_FAILED_LOG="$file_path/PULLED_IMAGES_FAILED_LOG.log"

if [ ! -f $PULLED_IMAGE_FAILED_LOG ]; then
        touch $PULLED_IMAGE_FAILED_LOG
fi



for Chart in ${helm_chart_file_list[@]}; do
        #imgs=`helm template  "$Chart" 2> /dev/null  |grep "image:" | sed -e 's/^[ ]*//g'  | sort -n | uniq | sed -e 's/\"//g'`
        ## imgae: Register/Registry/ImgName:Version
        img_list_tmp=$(helm template  "$Chart" 2> /dev/null  |grep "image:" | sed -e 's/^[ ]*//g' | sed -e 's/[ ]*$//g' -e "s/[\'\"]//g" -e 's/\s-//g' -e 's/^-//g' -e 's/^#//g'|sed -e 's/^[ ]*//g' | sort -u | uniq )
        img_list=$(echo "$img_list_tmp" | awk '{print $2}')
        
        echo -e "\n\n\n\n#############download $Chart images###################\n"
        echo -e "image list:\n$img_list\n\n\n\n"
        

        chart_file="${Chart##*/}"
        img_folder_name=$(basename ${chart_file} .tgz)
        if [ ! -d $img_folder_name ]; then
                mkdir -p $download_path/$img_folder_name
        fi
        echo -e "Create Image Folder $download_path/$img_folder_name\n\n"


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
                          if [[  "${universalMirrorArray[@]}" =~ $imgtagPrefix ]]; then
                                #tag 去掉registry后的部分，也就是没有了url的部分#
                                tmp=${i#*/}
                                mirrorPrefix=${imgtagPrefix%.*}
                                mirrorEnd=${imgtagPrefix##*.}
                                daocloudMirror="${imgtagPrefix%.*}.m.daocloud.$mirrorEnd"
                                if [[ $imgVer == $i ]]; then
                                        imgVer=latest
                                        i="$daocloudMirror/$tmp:$imgVer"
                                else
                                        i="$daocloudMirror/$tmp"
                                fi
                          ##    i="$daocloudMirror/$tmp"
                          ### 若镜像tag前缀是字符串，不是域名格式，则使用默认docker加速镜像源
                          elif [[ "${specialMirrorArray[@]}" =~ $imgtagPrefix  ]]; then
                                #tag 去掉registry后的部分，也就是没有了url的部分 
                                tmp=${i#*/}  
                                case $imgtagPrefix in
                                        k8s.gcr.io)
                                                daocloudMirror="k8s-gcr.m.daocloud.io" ;;
                                        registry.k8s.io)
                                                daocloudMirror="k8s.m.daocloud.io" ;;
                                        docker.elastic.co)
                                                daocloudMirror="elastic.m.daocloud.io" ;;
                                        mcr.microsoft.com)
                                                daocloudMirror="mcr.m.daocloud.io" ;;
                                        registry.jujucharms.com)
                                                daocloudMirror="jujucharms.m.daocloud.io" ;;
                                        rocks.canonical.com)
                                                daocloudMirror="rocks-canonical.m.daocloud.io" ;;
                                        *)
                                                exit
                                esac
                                ###镜像tag没有Version
                                if [[ $imgVer == $i ]]; then
                                        imgVer="latest"
                                        i="$daocloudMirror/$tmp:$imgVer"
                                else
                                        i="$daocloudMirror/$tmp"
                                fi
                          ##如果镜像前缀是字符串
                          elif [[ "$imgtagPrefix" =~ ^[a-zA-Z][-a-zA-Z0-9]{0,62}([a-zA-Z0-9][-a-zA-Z0-9]{0,62})+$ ]]; then
                           #镜像tag是否有Version
                            if [[ $imgVer == $i ]]; then
                                imgVer="latest"
                                i="$defaultMirror/$i:$imgVer"
                            ###  镜像tag有Version   
                            else
                                i="$defaultMirror/$i"
                            fi       
                          fi 
                        ### 镜像tag没有Registry Url
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
                        echo -e "pull  image:  $i"
                        pull_image_result=`docker pull $i`
                        if [ $? -eq 0 ]; then
                                echo -e "$pull_image_result"
                                echo -e "\nsave image: $download_path/$img_folder_name/$imgCom-$imgVer.tar\n"
                                ### 导出的镜像名字为 软件名称-版本.tar
                                docker save -o  "$download_path/$img_folder_name/$imgCom-$imgVer.tar" $i
                        else
                                echo -e "$pull_image_result"
                                echo -e "Helm Chart: $Chart\n" >> $PULLED_IMAGE_FAILED_LOG    
                                echo -e "Image: $i\n" $PULLED_IMAGE_FAILED_LOG
                                echo -e "Result: failure\n" >> $PULLED_IMAGE_FAILED_LOG
                                echo -e "Faliure Log:\n$pull_image_result\n\n\n\n" >> $PULLED_IMAGE_FAILED_LOG
                        fi
        done
        if [ $? -eq 0 ]; then
                echo $Chart >> $file_path/$PULLED_IMAGES_HELM_CHART_LIST
                sed -i "/$chart_file/d" $file_path/$WITHOUT_PULLING_IMAGES_HELM_CHART_LIST
        fi 
done

echo  -e "\n\n\nThe image required for the helm chart under the $file_path directory has been pulled ! ! !\n\n"
echo  -e "The log of image pull failure is in $PULLED_IMAGE_FAILED_LOG\n"
echo -e "Please check the failure log to analyze the reason of image pull failure, and pull the image again"

