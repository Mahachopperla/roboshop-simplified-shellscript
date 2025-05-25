#!/bin/bash

#few lines of code is common in all components(colr setting, log-file creation to store logs,checking user using root access or not)
. ./common.sh

APP_NAME=mysql

CHECK_ROOT



dnf install mysql-server -y &>> $LOG_FILE
VALIDATE $? "installation of mysql"

systemctl enable mysqld
systemctl start mysqld 

VALIDATE $? "mysqld service started successfully"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "setting root pass"

TIME_TAKEN