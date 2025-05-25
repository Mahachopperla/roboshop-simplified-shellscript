#!/bin/bash

#few lines of code is common in all components(colr setting, log-file creation to store logs,checking user using root access or not)
. ./common.sh

APP_NAME=payment
MYSQL_ROOT_PASSWORD=RoboShop@1


CHECK_ROOT



PYTHON_SETUP

USER_SETUP

APP_SETUP


SYSTEMD_SETUP

TIME_TAKEN

#give payment dns name in forntend nginx conf


