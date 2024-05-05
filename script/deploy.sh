#!/bin/bash
. ./common.sh

echo "Deploying $APP"

# Get Resources
exec_cmd "Get docker container file" "curl 'http://ec2-52-32-195-219.us-west-2.compute.amazonaws.com/api/v4/projects/851/repository/files/resources%2Fdocker%2FContainerfile?ref=resources&private_token=$REPO_PRIVATE_TOKEN' | jq -r '.content' |      base64 -d > Containerfile" true
exec_cmd "Get docker nginx-entrypoint" "mkdir -p resources && curl 'http://ec2-52-32-195-219.us-west-2.compute.amazonaws.com/api/v4/projects/851/repository/files/resources%2Fdocker%2Fnginx%2Fnginx-entrypoint.sh?ref=resources&&private_token=$REPO_PRIVATE_TOKEN' | jq -r '.content' |      base64 -d > resources\/nginx-entrypoint.sh" true
exec_cmd "Get docker nginx-template" "mkdir -p resources && curl 'http://ec2-52-32-195-219.us-west-2.compute.amazonaws.com/api/v4/projects/851/repository/files/resources%2Fdocker%2Fnginx%2Fnginx-template.conf?ref=resources&&private_token=$REPO_PRIVATE_TOKEN' | jq -r '.content' |      base64 -d > resources\/nginx-template.conf" true
exec_cmd "Get docker pwd-$ENV file" "curl 'http://ec2-52-32-195-219.us-west-2.compute.amazonaws.com/api/v4/projects/851/repository/files/resources%2Fdocker%2Fpwd%2Fpwd-$ENV.yml?ref=resources&&private_token=$REPO_PRIVATE_TOKEN' | jq -r '.content' | base64 -d > pwd-$ENV.yml" true
exec_cmd "Get docker apps json" "curl 'http://ec2-52-32-195-219.us-west-2.compute.amazonaws.com/api/v4/projects/851/repository/files/resources%2Fdocker%2Fapps%2Fapps.json?ref=resources&&private_token=$REPO_PRIVATE_TOKEN' | jq -r '.content' | base64 -d > apps.json" true
exec_cmd "Get docker custom-apps-$ENV json" "curl 'http://ec2-52-32-195-219.us-west-2.compute.amazonaws.com/api/v4/projects/851/repository/files/resources%2Fdocker%2Fapps%2Fcustom-apps-$ENV.json?ref=resources&&private_token=$REPO_PRIVATE_TOKEN' | jq -r '.content' | base64 -d > custom-apps-$ENV.json" true

# Encode apps.json to base64
exec_cmd "encode apps file to base64" "export APPS_JSON_BASE64=$(base64 -w 0 apps.json)" true
echo 'apps' $APPS_JSON_BASE64

# Encode customer-apps.json to base64
exec_cmd "encode custom apps file to base64" "export CUSTOM_APPS_JSON_BASE64=$(base64 -w 0 custom-apps-$ENV.json)" true
echo 'custom-apps' $CUSTOM_APPS_JSON_BASE64

# Get timestamp millis to be use as cachebust
export TIMESTAMP=$(date +%s%3N)
echo 'timestamp' $TIMESTAMP

# Building image
exec_cmd "Building $PROJ_NAME Image" "sudo docker build \
    --build-arg FRAPPE_PATH=https://github.com/frappe/frappe \
    --build-arg FRAPPE_BRANCH=version-14 \
    --build-arg PYTHON_VERSION=3.10.12 \
    --build-arg NODE_VERSION=16.20.2 \
    --build-arg APPS_JSON_BASE64=$APPS_JSON_BASE64 \
    --build-arg CUSTOM_APPS_JSON_BASE64=$CUSTOM_APPS_JSON_BASE64 \
    --build-arg CACHEBUST=$TIMESTAMP \
    --progress=plain \
    --tag=$PROJ_NAME:latest \
    --file=Containerfile ." true


# Remove site assets
exec_cmd "Removing $APP assets" "sudo docker exec -it pcsms-$ENV-backend-1 rm $ASSET_PATH"
# Start services
exec_cmd "Restart services" restart_services true
# Check site log
exec_cmd "Check $APP asset" "sudo docker exec -it pcsms-$ENV-backend-1 [ -d \"$ASSET_PATH\" ] && echo \"$APP assets are loaded\" || echo \"$APP assets are not loaded\""

echo "Deployment is successful."



