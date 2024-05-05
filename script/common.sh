#!/bin/bash

#Note - Change <env>, <site>, <private token> accordingly

export ENV=<env>
export APP=pcsms
export PROJ_NAME=$APP-$ENV
export SITE=<site>
export ASSET_PATH=/home/frappe/frappe-bench/sites/assets/pcsms
export REPO_PRIVATE_TOKEN=<private token>

exec_cmd() {
    local process_name="$1"
    local cmd="$2"
    local exit_flag="$3"

    # Enable 'set -e' if exit_flag is true
    if [ "$exit_flag" = true ]; then
        set -e
    else
        set +e
    fi

    echo $process_name
    eval $cmd
    if [ $? -eq 0 ]; then
        echo "Result: success"
    else
        echo "Result: failed"
    fi

    if [ -z "$cmd" ]; then
        echo "No command provided."
        return 1
    fi

    echo "-------------------------------------------"
}


restart_services() {
    exec_cmd "Shutting down $PROJ_NAME containers" "sudo docker compose -p $PROJ_NAME -f pwd-$ENV.yml down"
    exec_cmd "Starting uP $PROJ_NAME containers" "sudo docker compose -p $PROJ_NAME -f pwd-$ENV.yml up -d"
    sudo docker logs $PROJ_NAME-create-site-1 -f
    exec_cmd "Clearing $SITE cache" "sudo docker exec $PROJ_NAME-backend-1 bench --site $SITE clear-cache"
}