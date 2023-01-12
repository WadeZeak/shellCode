#!/bin/bash
#The operating system relies on the jq and skopeo commands


#The directory where the oci image file is located
oci_folder_path='/root/offline/oci'

#Filter oci image list according to oci index.json fil
oci_image_list=`cat $oci_folder_path/index.json | jq | grep org.opencontainers.image.ref.name | awk -F: '{print $2":"$3}' | sed -e 's/^[ ]*//g' | sed -e 's/[ ]*$//g' -e "s/[\'\"]//g"` 

echo -e "The oci image list is as follows:\n$oci_image_list\n\n\n"

## target registry
registry="10.120.9.10"

### Target repository, that is project
## Please ensure that there is a corresponding repository in the registry
repository=""

if [ -n "$repository" ]; then
        destRegistry=$registry/$repository
else
        destRegistry=$registry
fi

##registry account and password
registry_user=""
registry_passwd=""


## Whether the registry access protocol is http or https
access_protocol_type="https"

#skopeo copy failure log file
skopeo_copy_failure_log_file=SKOPEO_COPY_FAILUE_LOG.log
if [ ! -f $oci_folder_path/$skopeo_copy_failure_log_file ]; then
        touch $oci_folder_path/$skopeo_copy_failure_log_file
fi

#skopeo copy failed the OCI image list file
SKOPEO_COPY_FAILURE_OCI_IMAGE_LIST_FILE=SKOPEO_COPY_FAILURE_OCI_IMAGE.list

if [ ! -f $oci_folder_path/$SKOPEO_COPY_FAILURE_OCI_IMAGE_LIST_FILE ];then
        touch $oci_folder_path/$SKOPEO_COPY_FAILURE_OCI_IMAGE_LIST_FILE
        echo -e "$oci_image_list" > $oci_folder_path/$SKOPEO_COPY_FAILURE_OCI_IMAGE_LIST_FILE
fi

#skopeo copy successful OCI image list file
SKOPEO_COPY_SUCCESS_OCI_IMAGE_LIST_FILE=SKOPEO_COPY_SUCCESS_OCI_IMAGE.list
if [ ! -f $oci_folder_path/$SKOPEO_COPY_SUCCESS_OCI_IMAGE_LIST_FILE ]; then
        touch $oci_folder_path/$SKOPEO_COPY_SUCCESS_OCI_IMAGE_LIST_FILE
fi

skopeo_copy_oci_image_list=`sed  '/^[  ]*$/d'  $oci_folder_path/$SKOPEO_COPY_FAILURE_OCI_IMAGE_LIST_FILE `

skopeo_copy_success_oci_image_list=`cat $oci_folder_path/$SKOPEO_COPY_SUCCESS_OCI_IMAGE_LIST_FILE`

echo -e "Skepoe copy successful OCI image list:\n$skopeo_copy_success_oci_image_list\n\n"

echo -e "List of OCI images that need to be copied by skopeo:\n$skopeo_copy_oci_image_list\n\n"



echo -e "Start copying oci image from $oci_folder_path to registry $destRegistry/$repository...\n\n"

echo -e "============================== Skopeo Login Registry ==========================\n\n"

if [[ -n "$registry_user" ]]  && [[ -n "$registry_passwd"  ]]; then
        if [ $access_protocol_type == "http" ];then
                ### http 
                skopeo_login_registry_result=$(skopeo login -u $registry_user -p $registry_passwd $destRegistry  --tls-verify=false 2>&1 )
        else
                # https
                skopeo_login_registry_result=$(skopeo login -u $registry_user -p $registry_passwd $destRegistry   2>&1 )
        fi
        if [ $? -eq 0 ]; then
                if [ $access_protocol_type == "http" ];then 
                        echo -e "Skopeo login registry http://$destRegistry/$repository successfully ! ! !\n\n"
                else
                        echo -e "Skopeo login registry https://$destRegistry/$repository successfully ! ! !\n\n"
                fi 
        else
                if [ $access_protocol_type == "http" ];then
                        echo -e "Skopeo login registry http://$destRegistry/$repository failed ! ! ! \n\n"
                else
                        echo -e "Skopeo login registry https://$destRegistry/$repository failed ! ! ! \n\n"
                fi
                echo -e "Please check the error message, the error is as follows:\n$skopeo_login_registry_result\n\n"
                exit -1
        fi

elif [[  ! -n "$registry_user" ]]  && [[ ! -n "$registry_passwd"  ]]; then 
        if [ $access_protocol_type == "http" ]; then 
                echo -e "Registry  http://$destRegistry/$repository can copy OCI image by skopeo without usernamme and password ! ! !\n\n"
        else
                echo -e "Registry  https://$destRegistry/$repository can copy OCI image by skopeo without usernamme and password ! ! !\n\n"
        fi
else
        echo -e "Rrgistry username and password format error, please check login configuration ! ! !\n\n"
        exit -2
fi






echo -e "============================ Skopeo Copy OCI Image ============================\n\n"

for oci_image in ${skopeo_copy_oci_image_list[@]} ; do
        skopeo_cppy_result=$(skopeo copy --retry-times=3 --insecure-policy --src-tls-verify=false --dest-tls-verify=false oci://$oci_folder_path/../oci:$oci_image docker://$destRegistry/$oci_image)
        if [ $? -eq 0 ]; then
                echo -e "Skopeo copy OCI: $oci_image to $destRegistry/$oci_image successfully ! ! !"
                echo -e "$oci_image" >> $oci_folder_path/$SKOPEO_COPY_SUCCESS_OCI_IMAGE_LIST_FILE
                sed -i  "s@$oci_image@@g"  $oci_folder_path/$SKOPEO_COPY_FAILURE_OCI_IMAGE_LIST_FILE
        else
                echo -e "Skopeo copy OCI: $oci_image to $destRegistry/$oci_image failed ! ! !"
                echo -e "OCI Image: $oci_image" >> $oci_folder_path/$skopeo_copy_failure_log_file
                echo -e "Action: skopeo copy OCI:$oci_image to $destRegistry/$oci_image failed ! ! !" >> $oci_folder_path/$skopeo_copy_failure_log_file
                echo -e "The Executed Command: skopeo copy --retry-times=3 --insecure-policy --src-tls-verify=false --dest-tls-verify=false oci://$oci_folder_path/../oci:$oci_image docker://$destRegistry/$oci_image" >> $oci_folder_path/$skopeo_copy_failure_log_file
                echo -e "Failure log:\n$skopeo_cppy_result\n\n\n" >> $oci_folder_path/$skopeo_copy_failure_log_file
                echo -e "=======================================  DIVIDING  lINE ================================\n\n" >> $oci_folder_path/$skopeo_copy_failure_log_file
        fi
        echo -e "The Executed Command: skopeo copy --retry-times=3 --insecure-policy --src-tls-verify=false --dest-tls-verify=false oci://$oci_folder_path/../oci:$oci_image docker://$destRegistry/$oci_image\n"
        echo -e "$skopeo_cppy_result\n\n"
done

sed -i  '/^[ ]*$/d' $oci_folder_path/$SKOPEO_COPY_FAILURE_OCI_IMAGE_LIST_FILE


echo -e "Skopeo copy the OCI image from xxx  to xxx completed ! ! !\n"
echo -e "The OCI image log file that Skopeo failed to copy is in $oci_folder_path/$skopeo_copy_failure_log_file, please check the error log and copy again"
