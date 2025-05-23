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

echo "This script is getting executed at : $(date)" &>> $LOG_FILE 
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
#whatever location we are currently in, we need to copy mongodb.repo script from roboshop-shell-script dir so in starting of script only we are assigning it's value to script location variable

dnf module disable redis -y &>> $LOG_FILE
dnf module enable redis:7 -y &>> $LOG_FILE
VALIDATE $? "enabling redis package"

dnf install redis -y &>> $LOG_FILE
VALIDATE $? "enabling redis package"

sed -s 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>> $LOG_FILE

VALIDATE $? "updation of accepted hosts ip"

sed -s 's/"protection-mode yes"/"protection-mode no"/g' /etc/redis/redis.conf &>> $LOG_FILE

VALIDATE $? "updation of protection-mode"

systemctl enable redis &>> $LOG_FILE
systemctl start redis &>> $LOG_FILE

VALIDATE $? "redis service start"