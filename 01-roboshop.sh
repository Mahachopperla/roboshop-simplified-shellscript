#!/bin/bash

#let's create variables AMI ID, SG ID, instances array

AMI_ID=ami-09c813fb71547fc4f
SG_ID=sg-03de6c7ee76a1f5a3
INSTANCES=("mysql" "frontend") #how many instances you need give their names here
ZONE_ID=Z02829133T93YRRJ2VRGM
DOMAIN_NAME=robotshop.site

# now let's write a for loop which creates any no.of instances based on list
# provided in instances array

for instance in ${INSTANCES[@]}
do
# search in google for script to create instances in aws cli
#modify the script based on ur needs
#here i dont want key pair, subnet etc so removed those portions and taken which is required for me
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-03de6c7ee76a1f5a3 --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=$instance}]' --query "Instances[*].InstanceId" --output text)
    
    if ( $instance -eq frontend )
    then
        IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
        echo " $instance: $IP"
    else
        IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
        echo "$instance : $IP"
    fi

done
