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


curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $LOG_FILE
rm -rf /app/*
cd /app
unzip /tmp/catalogue.zip &>> $LOG_FILE
npm install &>> $LOG_FILE
VALIDATE $? "build tool installed packages"

cp $SCRIPT_LOCATION/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "systemctl service file copying"

systemctl daemon-reload
systemctl enable catalogue 
systemctl start catalogue
VALIDATE $? "validating and running service"

cp $SCRIPT_LOCATION/mongodb.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-mongosh -y &>> $LOG_FILE
VALIDATE $? "installation of mongo client "



DB_EXISTS=$(mongosh --quiet --host mongodb.robotshop.site --eval "db.adminCommand('listDatabases').databases.map(db => db.name).includes('catalogue')")
if [ "$DB_EXISTS" == "true" ]; then
    mongosh --host mongodb.robotshop.site </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loading data into MongoDB"
else
    echo -e "Data is already loaded ... $Y SKIPPING $N"
fi









