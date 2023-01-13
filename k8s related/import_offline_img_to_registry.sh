#!/bin/bash

#The directory where the image file is located
offline_image_file_path='/root/chart_image'

#Search for image files ending in .tar
offline_image_file_list=`find $offline_image_file_path -type f | grep -E '*.tar$'`

echo -e "The list of all offline mirror files is as follows:\n$offline_image_file_list\n\n\n"

### registry url
registry="10.120.9.10"

## Target repository, that is project
## Please ensure that there is a corresponding repository in the registry
repository=""

### target registry
if [ -n "$repository" ]; then
        destRegistry=$registry/$repository
else
        destRegistry=$registry
fi

##registry account and password
registry_user=""
registry_passwd=""



## Whether the registry access protocol is http or https
access_protocol_type="http"







#push image failure log file
PUSH_IMAGE_FAILURE_LOG_FILE=PUSH_IMAGE_FAILUE_LOG.log
if [ ! -f $offline_image_file_path/$PUSH_IMAGE_FAILURE_LOG_FILE ]; then
        touch $offline_image_file_path/$PUSH_IMAGE_FAILURE_LOG_FILE
fi

#push  failed  image list file
PUSH_IMAGE_FAILURE_LIST_FILE=PUSH_IMAGE_TO_REGISTRY_FAILURE.list

if [ ! -f $offline_image_file_path/$PUSH_IMAGE_FAILURE_LIST_FILE ];then
        touch $offline_image_file_path/$PUSH_IMAGE_FAILURE_LIST_FILE 
        echo  "$offline_image_file_list" > $offline_image_file_path/$PUSH_IMAGE_FAILURE_LIST_FILE
fi

#push  successfully  image list file
PUSH_IMAGE_SUCCESS_LIST_FILE=PUSH_IMAGE_TO_REGISTRY_SUCCESS.list
if [ ! -f $offline_image_file_path/$PUSH_IMAGE_SUCCESS_LIST_FILE ]; then
        touch $offline_image_file_path/$PUSH_IMAGE_SUCCESS_LIST_FILE
fi

pushed_image_success_list=`cat $offline_image_file_path/$PUSH_IMAGE_SUCCESS_LIST_FILE`

need_to_be_pushed_image_list=`sed  '/^[  ]*$/d' $offline_image_file_path/$PUSH_IMAGE_FAILURE_LIST_FILE`

echo -e "Push to registry successful image file list:\n$pushed_image_success_list\n\n"

echo -e "The list of image files that need to be pushed to the registry:\n$need_to_be_pushed_image_list\n\n"






echo -e "============================================= Try To  Login Registry ====================================================\n\n"

if [[ -n "$registry_user" ]]  && [[ -n "$registry_passwd"  ]]; then
                ### http 
        login_registry_result=$(docker login -u $registry_user -p $registry_passwd $destRegistry  --tls-verify=false 2>&1 )
        if [ $? -eq 0 ]; then
                echo -e "login registry http[s]://$destRegistry successfully ! ! !\n\n"
                ehco -e "$login_registry_result"
        else
                echo -e "login registry http[s]://$destRegistry failed ! ! ! \n\n"
                echo -e "Please check the error message, the error is as follows:\n$login_registry_result\n\n"
                exit -1
        fi

elif [[  ! -n "$registry_user" ]]  && [[ ! -n "$registry_passwd"  ]]; then 
        echo -e "You can push the image to $login_registry_result without usernamme and password ! ! !\n\n"
else
        echo -e "Rrgistry username and password format error, please check login configuration ! ! !\n\n"
        exit -2
fi





echo -e "============================================ Push  Image to Registry ================================================\n\n"


for offline_img in ${need_to_be_pushed_image_list[@]} ; do
        load_image_result=`docker load -i $offline_img 2>&1`
        if [ $? -eq 0 ]; then
                echo -e "Load image $offline_img successfully ! ! !"
                echo -e "$load_image_result\n"
        else
                echo -e "Load image $offline_img failed ! ! !"
                echo -e "The error message is as follows:\n$load_image_result\n\n"

                #dump failure log to log  file
                echo -e "Offline image file: $offline_img" >> $offline_image_file_path/$PUSH_IMAGE_FAILURE_LOG_FILE 
                echo -e "Executed command: docker load -i $offline_img" >> $offline_image_file_path/$PUSH_IMAGE_FAILURE_LOG_FILE
                echo -e "Result: failed to load image $offline_img failed ! ! !" >> $offline_image_file_path/$PUSH_IMAGE_FAILURE_LOG_FILE
                echo -e "Failure message: $load_image_result" >> $offline_image_file_path/$PUSH_IMAGE_FAILURE_LOG_FILE
                echo -e "\n\n\n===================================== Dividing line  ===========================================\n\n\n" >> $offline_image_file_path/$PUSH_IMAGE_FAILURE_LOG_FILE
                continue
        fi
        ### Filter image tags from the output of the load image
        original_image_tag=${load_image_result##* }
#       OriMirror=$(echo  $imgTagOri | awk -F'/' '{print $1}')
#       echo $imgTagOri
#       echo $OriMirror 
        ### get image registry url
        original_image_registry_url=$(echo  $original_image_tag | awk -F'/' '{print $1}')
        
        ### Determine whether the image registry  is in domain name format
#        if [[ "$original_image_registry_url" =~ ^[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+ ]]; then
                ### Replace the original registry url of the image with the address of the target registry
#                current_image_tag=$(echo $original_image_tag | sed "s@$original_image_registry_url@$destRegistry@g")
#        else
                current_image_tag="$destRegistry/$original_image_tag"
#        fi
        current_image_tag="$destRegistry/$original_image_tag"
        docker tag $original_image_tag $current_image_tag

        
        push_image_result=`docker push $current_image_tag  2>&1`

        if [ $? -eq 0  ]; then
                echo -e "Push image $current_image_tag to registry $destRegistry successfully ! ! !"
                echo -e "$push_image_result\n\n"

                #Push image status record
                echo -e "$offline_img" >> $offline_image_file_path/$PUSH_IMAGE_SUCCESS_LIST_FILE
                sed -i "s@$offline_img@@g" $offline_image_file_path/$PUSH_IMAGE_FAILURE_LIST_FILE
        else
                echo -e "Push image $current_image_tag to registry $destRegistry failed ! ! !"
                echo -e "The error message is as follows:\n$push_image_result\n\n"

                #dump failure log to log file
                echo -e "Offline image file: $offline_img" >> $offline_image_file_path/$PUSH_IMAGE_FAILURE_LOG_FILE
                echo -e "Original image tag: $original_image_tag" >> $offline_image_file_path/$PUSH_IMAGE_FAILURE_LOG_FILE
                echo -e "Current image tag: $current_image_tag" >> $offline_image_file_path/$PUSH_IMAGE_FAILURE_LOG_FILE
                echo -e "Executed Command: docker push $current_image_tag" >> $offline_image_file_path/$PUSH_IMAGE_FAILURE_LOG_FILE
                echo -e "Result: Push image $current_image_tag to registry $destRegistry failed ! ! !" >> $offline_image_file_path/$PUSH_IMAGE_FAILURE_LOG_FILE
                echo -e "Failure message: $push_image_result" >> $offline_image_file_path/$PUSH_IMAGE_FAILURE_LOG_FILE
                echo -e "\n\n\n===================================== Dividing line  ===========================================\n\n\n" >> $offline_image_file_path/$PUSH_IMAGE_FAILURE_LOG_FILE
        fi
done

sed -i '/^[ ]*$/d' $offline_image_file_path/$PUSH_IMAGE_FAILURE_LIST_FILE

echo  -e "\n\n\nPush the offline image to $destRegistry complete ! ! !\n\n"
echo  -e "The log of image push failure is at $offline_image_file_path/$PUSH_IMAGE_FAILURE_LOG_FILE .\n"
echo -e "Please check the failure log and analyze the reason for the image push failure, and then push the image again ! ! !"
