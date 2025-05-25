#!/bin/bash

#few lines of code is common in all components(colr setting, log-file creation to store logs,checking user using root access or not)

. ./common.sh

CHECK_ROOT





dnf list installed nginx &>> $LOG_FILE 

if [ $? -ne 0 ]  
then
    echo -e "$Y installing nginx.......$N" | tee -a $LOG_FILE
    dnf module disable nginx -y &>> $LOG_FILE
    dnf module enable nginx:1.24 -y &>> $LOG_FILE
    VALIDATE $? "enabling nginx:1.24"

    dnf install nginx -y &>> $LOG_FILE
    VALIDATE $? "installation of nginx"  

else
    echo -e "$G nginx is already installed... nothing to do$N" | tee -a $LOG_FILE
fi

systemctl enable nginx &>> $LOG_FILE
systemctl start nginx &>> $LOG_FILE
VALIDATE $? "started nginx service"

rm -rf /usr/share/nginx/html/* 

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $LOG_FILE

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>> $LOG_FILE
VALIDATE $? "frontend app file copying "


cp $SCRIPT_LOCATION/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? " nginx.conf file updation"

systemctl restart nginx &>> $LOG_FILE
VALIDATE $? "service restart "

TIME_TAKEN