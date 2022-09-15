export file_path='/root/offline/'
export imgs_folder=`find $file_path -name  "*.tar"`
export destRegistry="10.120.0.31:30880/daocloud"

for offline_imgs in $imgs_folder ; do
        Output=`docker load -i $offline_imgs`
        imgTagOri=${Output##* }
#       OriMirror=$(echo  $imgTagOri | awk -F'/' '{print $1}')
#       echo $imgTagOri
#       echo $OriMirror 
        imgTagPrefix=$(echo  $imgTagOri | awk -F'/' '{print $1}')
        if [[ "$imgTagPrefix" =~ ^[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+ ]]; then
#               echo  $imgTagPrefix
                img=$(echo $imgTagOri | sed "s@$imgTagPrefix@$destRegistry@g")
        else
                img="$destRegistry/$imgTagOri"
        fi
#        echo $img
        docker tag $imgTagOri $img
        docker push $img
done
