export file_path='/root/helm-chart/'
export imgs_folder=`find $file_path -name  "*.tar"`
export destRegistry="10.120.0.31:30880/daocloud"

for offline_imgs in $imgs_folder ; do
        Output=`docker load -i $offline_imgs`
        imgTagOri=${Output##* }
        OriMirror=$(echo  $imgTagOri | awk -F'/' '{print $1}')
#       echo $imgTagOri
#       echo $OriMirror         
        img=$(echo $imgTagOri | sed "s@$OriMirror@$destRegistry@g")
        docker tag $imgTagOri $img
        docker push $img
done
