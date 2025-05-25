#!/bin/bash

#few lines of code is common in all components(colr setting, log-file creation to store logs,checking user using root access or not)
. ./common.sh

APP_NAME=rabbitmq
CHECK_ROOT


cp $SCRIPT_LOCATION/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "copying of repo file"

dnf install rabbitmq-server -y &>> $LOG_FILE
VALIDATE $? "rabbitmq installation"

systemctl enable rabbitmq-server
systemctl start rabbitmq-server
VALIDATE $? "starting of rabbitmq"


rabbitmqctl add_user roboshop roboshop123 &>> $LOG_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOG_FILE
VALIDATE $? "user created successfully"

TIME_TAKEN