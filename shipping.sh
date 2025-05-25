#!/bin/bash

#few lines of code is common in all components(colr setting, log-file creation to store logs,checking user using root access or not)
. ./common.sh


APP_NAME=shipping

CHECK_ROOT
USER_SETUP
APP_SETUP #app setup should de first and then follow it by maven setup
MAVEN_SETUP



SYSTEMD_SETUP

dnf install mysql -y &>> $LOG_FILE
VALIDATE $? "mysql client isntallation"

mysql -h mysql.robotshop.site -u root -p$MYSQL_ROOT_PASSWORD -e 'use cities' &>>$LOG_FILE
if [ $? -ne 0 ]
then
    mysql -h mysql.robotshop.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql &>>$LOG_FILE
    mysql -h mysql.robotshop.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql  &>>$LOG_FILE
    mysql -h mysql.robotshop.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql &>>$LOG_FILE
    VALIDATE $? "Loading data into MySQL"
else
    echo -e "Data is already loaded into MySQL ... $Y SKIPPING $N"
fi

systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Restart shipping"

TIME_TAKEN

#give shipping dns name in forntend nginx conf
