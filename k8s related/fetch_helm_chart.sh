#!/bin/bash

export helm_repo_name=(
hashicorp
)

### helm chart url 顺序需要和helm chart repo name 对应
export helm_repo_url=(
https://helm.releases.hashicorp.com
)



#repo_amount= ${#helm_repo_name[@]}

####add helm repo
for ((i=0; i< ${#helm_repo_name[@]} ; i++)); do
  echo " add helm repo ${helm_repo_name[i]} ${helm_repo_url[i]}"
  helm  repo add ${helm_repo_name[i]}  ${helm_repo_url[i]}
done

###update repo
 helm repo update

####download directory
##create dirirectory
download_path="./hashicorp"
mkdir -p $download_path


###download latest dce5 helm chart


for repo_name in ${helm_repo_name[@]}; do 
  echo -e "\n\n\n #################### download $repo_name Charts ################\n\n "
  chart_list=$(helm search repo $repo_name)
  echo -e "$chart_list\n\n"
  num=`echo "$chart_list" | wc -l`
#  echo $num
  for i in `seq $[ $num-1 ] -1 1`; do 
   # echo "$chart_list"  | tail -n $i | head -n 1 
    chart_name=`echo "$chart_list"  | tail -n $i | head -n 1 | awk  '{print $1}'`
    chart_version=`echo "$chart_list"  | tail -n $i | head -n 1 | awk  '{print $2}'`
    echo -e  "pull helm chart $chart_name  version: $chart_version\n"
    helm pull $chart_name --version $chart_version --destination  $download_path
  done 
done
