#!/bin/bash

#few lines of code is common in all components(colr setting, log-file creation to store logs,checking user using root access or not)
. ./common.sh


APP_NAME=Mongodb


CHECK_ROOT

#whatever location we are currently in, we need to copy mongodb.repo script from roboshop-shell-script dir so in starting of script only we are assigning it's value to script location variable

cp $SCRIPT_LOCATION/mongodb.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "COPYING MONGODB"

echo "installing mongod-db..please wait"
dnf install mongodb-org -y &>> $LOG_FILE
VALIDATE $? "mongo-db installation"

systemctl enable mongod
systemctl start mongod 
VALIDATE $? "enabling and staring mongo-db service"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf
VALIDATE $? "updating mongodb.conf file"

END_TIME=$(date +%s)
TIME_TAKEN=$(($END_TIME - $START_TIME))
echo "time taken to execute script is $TIME_TAKEN"