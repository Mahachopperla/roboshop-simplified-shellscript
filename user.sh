#!/bin/bash

#few lines of code is common in all components(colr setting, log-file creation to store logs,checking user using root access or not)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

START_TIME=$(date +%s)
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

dnf list installed nodejs &>> $LOG_FILE 

if [ $? -ne 0 ]  
then
    echo -e "$Y installing Nodejs.......$N" | tee -a $LOG_FILE
    dnf module disable nodejs -y &>> $LOG_FILE
    dnf module enable nodejs:20 -y &>> $LOG_FILE
    VALIDATE $? "enabling nodejs:20"

    dnf install nodejs -y &>> $LOG_FILE
    VALIDATE $? "installation of nodejs:20"  

else
    echo -e "$G Nodejs is already installed... nothing to do$N" | tee -a $LOG_FILE
fi

id roboshop &>> $LOG_FILE
if [ $? -ne 0 ]
then
    echo " user not there proceeding to create "
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else
    echo " user already existing so skipping user creation"
fi

mkdir -p /app # creates dir if not existing if existing it skips creation without giving error

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>> $LOG_FILE
VALIDATE $? "copying application code"

rm -rf /app/*
cd /app &>> $LOG_FILE 

unzip /tmp/user.zip &>> $LOG_FILE

cd /app 
npm install &>> $LOG_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_LOCATION/user.service /etc/systemd/system/user.service

VALIDATE $? "copying user service"

systemctl daemon-reload 
VALIDATE $? "daemon-reload"

systemctl enable user 
VALIDATE $? "enabling user"

systemctl start user
VALIDATE $? "starting user.service"

END_TIME=$(date +%s)
TIME_TAKEN=$($END_TIME-$START_TIME)
echo "time taken to execute script is $TIME_TAKEN"

