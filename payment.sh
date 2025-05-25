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
MYSQL_ROOT_PASSWORD=RoboShop@1

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

dnf install python3 gcc python3-devel -y &>> $LOG_FILE
VALIDATE $? "installation of python"

id roboshop &>> $LOG_FILE
if [ $? -ne 0 ]
then
    echo " user not there proceeding to create "
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else
    echo " user already existing so skipping user creation"
fi

mkdir -p /app 

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>> $LOG_FILE
VALIDATE $? "downloading application code"
rm -rf /app/*
cd /app 
unzip /tmp/payment.zip &>> $LOG_FILE
VALIDATE $? "unzipping folder"

pip3 install -r requirements.txt &>> $LOG_FILE
VALIDATE $? "dependencies installation"

cp $SCRIPT_LOCATION/payment.service /etc/systemd/system/payment.service &>> $LOG_FILE
VALIDATE $? "copying of files "

systemctl daemon-reload
VALIDATE $? "deamon-reload "

systemctl enable payment 
systemctl start payment
VALIDATE $? "payment serive started "

END_TIME=$(date +%s)
TIME_TAKEN=$($END_TIME-$START_TIME)
echo "time taken to execute script is $TIME_TAKEN"




