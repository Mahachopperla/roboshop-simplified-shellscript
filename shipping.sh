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

dnf install maven -y &>> $LOG_FILE
VALIDATE $? "maven installation"

id roboshop &>> $LOG_FILE
if [ $? -ne 0 ]
then
    echo " user not there proceeding to create "
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
else
    echo " user already existing so skipping user creation"
fi

mkdir -p /app

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>> $LOG_FILE
VALIDATE $? "downloading application code"

rm -rf /app/* &>> $LOG_FILE
cd /app 
unzip /tmp/shipping.zip &>> $LOG_FILE

VALIDATE $? "unzipping app files"


cd /app 
mvn clean package &>> $LOG_FILE
mv target/shipping-1.0.jar shipping.jar &>> $LOG_FILE

VALIDATE $? "installing dependencies"

cp $SCRIPT_LOCATION/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "service file copy"

systemctl daemon-reload &>> $LOG_FILE

systemctl enable shipping &>> $LOG_FILE
VALIDATE $? "service enabled"
systemctl start shipping &>> $LOG_FILE
VALIDATE $? "service started"

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

END_TIME=$(date +%s)
TIME_TAKEN=$(($END_TIME - $START_TIME))
echo "time taken to execute script is $TIME_TAKEN"