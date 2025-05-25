#!/bin/bash

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

CHECK_ROOT(){
    USERID=$(id -u)  #user id of root user will be 0

    if [ $USERID -ne 0 ]
    then
        echo -e "$R ERROR:$N $Y please run command with root access to execute succesfully$N " | tee -a $LOG_FILE
        exit 1
    fi
}

VALIDATE(){
    if [ $1 -eq 0 ]
        then
            echo -e " $G  $2 is successfull $N" | tee -a $LOG_FILE
        else
            echo -e " $R  $2 is failed $N" | tee -a $LOG_FILE
            exit 1
    fi
}

NODEJS_SETUP(){
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

    npm install &>> $LOG_FILE
    VALIDATE $? "build tool installed packages"
}

USER_SETUP(){
id roboshop &>> $LOG_FILE
if [ $? -ne 0 ]
then
    echo " user not there proceeding to create "
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else
    echo " user already existing so skipping user creation"
fi
}

APP_SETUP(){
    mkdir -p /app # creates dir if not existing if existing it skips creation without giving error


    curl -o /tmp/$APP_NAME.zip https://roboshop-artifacts.s3.amazonaws.com/$APP_NAME-v3.zip &>> $LOG_FILE
    rm -rf /app/*
    cd /app
    unzip /tmp/$APP_NAME.zip &>> $LOG_FILE
}

SYSTEMD_SETUP(){
    cp $SCRIPT_LOCATION/$APP_NAME.service /etc/systemd/system/$APP_NAME.service
    VALIDATE $? "systemctl service file copying"

    systemctl daemon-reload
    systemctl enable $APP_NAME 
    systemctl start $APP_NAME
    VALIDATE $? "validating and running service"

    

}

TIME_TAKEN(){

    END_TIME=$(date +%s)
    TIME_TAKEN=$(($END_TIME - $START_TIME))
    echo "time taken to execute script is $TIME_TAKEN"
}