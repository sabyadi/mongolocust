#!/bin/bash

# exit when any command fails
set -e

# set locust primary host
declare master=$(terraform output locust_master_dns | tr -d '"')

# List of locust worker hosts
declare -a workerList=$(terraform output locust_workernodes_dns | sed -r 's/[][,]//g' )

# set ssh keyfile path
declare sshKeyPath=$(terraform output ssh_keyfile_path | tr -d '"')

# killing worker nodes
echo "killing worker nodes"
for host in ${workerList[@]}; do
    host=$(echo ${host} | tr -d '"')
    echo $host
    ssh -o StrictHostKeyChecking=accept-new -i ${sshKeyPath} ec2-user@${host} "pkill locust"
done

# check parameter if master should also be killed
if [ $1 = "all" ]; then
    echo "killing locust master"

    ssh -o StrictHostKeyChecking=accept-new -i ${sshKeyPath} ec2-user@${master} "pkill locust"
fi

echo "done!"
