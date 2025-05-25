#!/bin/bash

#few lines of code is common in all components(colr setting, log-file creation to store logs,checking user using root access or not)
. ./common.sh

APP_NAME=catalogue
CHECK_ROOT
USER_SETUP
APP_SETUP
NODEJS_SETUP
SYSTEMD_SETUP


cp $SCRIPT_LOCATION/mongodb.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-mongosh -y &>> $LOG_FILE
VALIDATE $? "installation of mongo client "



DB_EXISTS=$(mongosh --quiet --host mongodb.robotshop.site --eval "db.adminCommand('listDatabases').databases.map(db => db.name).includes('catalogue')")
if [ "$DB_EXISTS" == "false" ]
then
    mongosh --host mongodb.robotshop.site </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loading data into MongoDB"
else
    echo -e "Data is already loaded ... $Y SKIPPING $N"
fi

TIME_TAKEN







