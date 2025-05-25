#!/bin/bash

#few lines of code is common in all components(colr setting, log-file creation to store logs,checking user using root access or not)
. ./common.sh


CHECK_ROOT

#whatever location we are currently in, we need to copy mongodb.repo script from roboshop-shell-script dir so in starting of script only we are assigning it's value to script location variable

dnf module disable redis -y &>> $LOG_FILE
dnf module enable redis:7 -y &>> $LOG_FILE
VALIDATE $? "enabling redis package"

dnf install redis -y &>> $LOG_FILE
VALIDATE $? "installtion of redis package"


sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
VALIDATE $? "updation of accepted hosts ip"

sudo sed -ri 's#^(protected-mode)[[:space:]]+yes#\1 no#' /etc/redis/redis.conf &>> $LOG_FILE
VALIDATE $? "updation of protection-mode"

systemctl enable redis &>> $LOG_FILE
systemctl start redis &>> $LOG_FILE

VALIDATE $? "redis service start"

systemctl restart redis &>> $LOG_FILE
VALIDATE $? "redis service restarted"

TIME_TAKEN