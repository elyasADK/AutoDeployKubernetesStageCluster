#!/bin/sh
username_password_base64=$(echo -n $docker_username:$docker_password | base64)
dockerNamespace="........"

# the name of projects in Dockerhub, that we want to control them
# dont forget to add your labels component. If you haven’t any label component just remove them from this code.
project_names=`kubectl get pods -o json \
               | jq '.items[] | select(.metadata.labels.component == "........" or .component == "........")' \
               | grep -i imageid | awk -F'[/]' '{print $3}' | awk -F'[@]' '{print $1}' | uniq`
for project in $project_names; do

# get token of dockerhub to connect to the dockerhub api
# dont forget to add your labels component. If you haven’t any label component just remove them from this code.
tag=`kubectl get pods -o json \
    | jq '.items[] | select(.metadata.labels.component == "......." or .component == ".........")' \
    | jq -r '.spec.containers[0].image' | uniq | grep $project | cut -d":" -f 2`

TOKEN=$(curl -s -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
        -H "Authorization: Basic ${username_password_base64}" \
        "https://auth.docker.io/token?service=registry.docker.io&scope=repository:$dockerNamespace/$project:pull" \
        | jq -r .token)

# get SHA of images from Dockerhub
dockerhub_image_sha=`curl -s -D - -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
        "https://index.docker.io/v2/$dockerNamespace/$project/manifests/$tag" \
        | grep etag | awk -F'[/"]' '{print $2}'`

# get SHA of images on cluster (running pods of projects)
pod=`echo -n "$project" > ./pod.env && sed -i 's/play-//' pod.env && cat pod.env`
pod_name=`kubectl get pods | grep "$pod" | awk '{ print $1 }'`
running_image_sha=`kubectl get pods $pod_name -o json | grep -i imageid | cut -d "@" -f 2 | awk -F'[/"]' '{print $1}' | awk 'NR==1{print $1}'`

# show name and SHA of projects on dockerhub and cluster (running pods of projects)
echo $project
echo "docker: $dockerhub_image_sha" && echo -e "kuber : $running_image_sha"

# compare the SHA
if [ $dockerhub_image_sha != $running_image_sha ] ; then
    kubectl delete pods $pod_name 1>/dev/null
    echo -e "$project restarted\n"
    else
    echo -e "$project no need to restart \n"
    echo ""
fi

done
