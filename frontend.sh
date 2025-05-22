#!/bin/bash

#few lines of code is common in all components(colr setting, log-file creation to store logs,checking user using root access or not)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


LOG_FOLDER="/var/log/roboshop-shellpractice" 
FILE_NAME=$(echo $0 | cut -d "." -f1) 
LOG_FILE="$LOG_FOLDER/$FILE_NAME.log"
mkdir -p $LOG_FOLDER
SCRIPT_LOCATION=$PWD

echo "This script is getting executed at : $(date)" | tee -a $LOG_FILE 
USERID=$(id -u)  #user id of root user will be 0

if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR:$N $Y please run command with root access to execute succesfully$N " | tee -a $LOG_FILE
    exit 1
fi


VALIDATE(){
    if [ $1 -eq 0 ]
        then
            echo -e " $G  $2 is successfull $N" | tee -a $LOG_FILE
        else
            echo -e " $R  $2 is failed $N" | tee -a $LOG_FILE
            exit 1
    fi
}

dnf list installed nginx &>> $LOG_FILE 

if [ $? -ne 0 ]  
then
    echo -e "$Y installing Nginx.......$N" | tee -a $LOG_FILE
    dnf module disable Nginx -y &>> $LOG_FILE
    dnf module enable Nginx:1.24 -y &>> $LOG_FILE
    VALIDATE $? "enabling Nginx:1.24"

    dnf install Nginx -y &>> $LOG_FILE
    VALIDATE $? "installation of Nginx"  

else
    echo -e "$G Nginx is already installed... nothing to do$N" | tee -a $LOG_FILE
fi

systemctl enable nginx &>> $LOG_FILE
systemctl start nginx &>> $LOG_FILE
VALIDATE $? "started Nginx service"

rm -rf /usr/share/nginx/html/* 

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $LOG_FILE

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>> $LOG_FILE
VALIDATE $? "frontend app file copying "

cp $SCRIPT_LOCATION/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? " nginx.conf file updation"

systemctl restart nginx &>> $LOG_FILE
VALIDATE $? "service restart "

