#!/bin/bash

#few lines of code is common in all components(colr setting, log-file creation to store logs,checking user using root access or not)
. ./common.sh


CHECK_ROOT


NODEJS_SETUP

USER_SETUP

APP_SETUP
APP_NAME=user


TIME_TAKEN

