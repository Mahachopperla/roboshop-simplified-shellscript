#!/bin/bash

#few lines of code is common in all components(colr setting, log-file creation to store logs,checking user using root access or not)
. ./common.sh

APP_NAME=catalogue
CHECK_ROOT
USER_SETUP
#make sure u call app setup first and nodejs setup next
#cause build tool is application specific it is diiferent for each application 
#for nodejs it is npm, for java it is maven and python pip etc
#so even though bild files need to be executed in app-setup we are writing build tool execution in that specific application installation process
#manam first nodejs run chesthye manam npm install ani call cheshety dhantlo dependencies inka load avaledhu
#manam depencies app lo load chesi then npm install ni call cheyali
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

#make sure to update user dns in nginx conf file of frontend





