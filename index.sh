#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
echo $3
if [[ "$3" ]];
then
    AMI_ID=$(jq -r '.builds[-1].artifact_id' ./packer/manifest.json | cut -d ":" -f2)
    echo $AMI_ID
    cd ./terraform/ec2

    terraform destroy -var="access_key=$1" \
        -var="secret_key=$2" \
        -var="ami_id=$AMI_ID" \
        -var-file=variables.tfvars

    cd ../../
else
    # create AMI NGINX
    cd ./packer
    export AWS_ACCESS_KEY_ID=$1
    export AWS_SECRET_ACCESS_KEY=$2
    packer build index.json
    cd ../

    # print created AMI ID
    # AMI_ID=$(jq -r '.builds[-1].artifact_id' ./packer/manifest.json | cut -d ":" -f2)
    # echo ami $AMI_ID
    

    #create EC2 Instance
    cd ./terraform/ec2
    terraform init -upgrade
    terraform apply -var="access_key=$1" \
        -var="secret_key=$2" \
        -var-file=variables.tfvars

    terraform output aws_instance >> "$SCRIPT_DIR/ansible/inventories"

    cd ../../ansible/

    ansible-playbook -i inventories nginx-container.yml -e "aws_access_key=$1" -e "aws_secret_key=$2"

    cd ../
fi
