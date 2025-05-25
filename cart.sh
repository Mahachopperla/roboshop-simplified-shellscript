#!/bin/bash

#few lines of code is common in all components(colr setting, log-file creation to store logs,checking user using root access or not)
. ./common.sh

APP_NAME=cart
CHECK_ROOT

APP_SETUP
NODEJS_SETUP

USER_SETUP




SYSTEMD_SETUP

TIME_TAKEN

#make sure to update user dns in nginx conf file of frontend