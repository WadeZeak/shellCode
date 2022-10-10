#!/bin/bash

#dce5_component
#hwameistor
#ghippo
#kpanda
#insight
#insight-agent
#kairship
#amamba
#skoala
#mspider

###helm chart repo name
export dce5_components_helm_repo_name=(
hwameistor
ghippo-release
kpanda-release
insight-release
kairship-release
amamba-release
skoala-release
mspider
)

### helm chart url 顺序需要和helm chart repo name 对应
export dce5_components_helm_repo_url=(
http://hwameistor.io/hwameistor                         
https://release.daocloud.io/chartrepo/ghippo            
https://release.daocloud.io/chartrepo/kpanda            
https://release.daocloud.io/chartrepo/insight           
https://release.daocloud.io/chartrepo/kairship          
https://release.daocloud.io/chartrepo/amamba            
https://release.daocloud.io/chartrepo/skoala            
https://release.daocloud.io/chartrepo/mspider           
)



#repo_amount= ${#dce5_components_helm_repo_name[@]}

####add helm repo
for ((i=0; i< ${#dce5_components_helm_repo_name[@]} ; i++)); do
  echo " add helm repo ${dce5_components_helm_repo_name[i]} ${dce5_components_helm_repo_url[i]}"
  helm  repo add ${dce5_components_helm_repo_name[i]}  ${dce5_components_helm_repo_url[i]}
done

###update repo
 helm repo update

####download directory
##create dir

mkdir -p ./dce5_components/helm_chart


###download latest dce5 helm chart


for repo_name in ${dce5_components_helm_repo_name[@]}; do 
  chart_list=$(helm search repo $repo_name)
  num=`echo "$chart_list" | wc -l`
#  echo $num
  for i in `seq $[ $num-1 ] -1 1`; do 
   # echo "$chart_list"  | tail -n $i | head -n 1 
    chart_name=`echo "$chart_list"  | tail -n $i | head -n 1 | awk  '{print $1}'`
    chart_version=`echo "$chart_list"  | tail -n $i | head -n 1 | awk  '{print $2}'`
    echo  "pull helm chart $chart_name  version: $chart_version"
    helm pull $chart_name --version $chart_version --destination  ./dce5_components/helm_chart
  done 
done
