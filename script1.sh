#!/bin/bash

echo " Hi this is script 1"
echo " PID of current script : $$"

. ./script2.sh



# We have 2 ways to call one script from other script
# 1. ./filename.sh
# 2. source ./filename.sh or . ./filename.sh

# if we create using case 1:
# then 
#     we need to give execute permission for other script to get it called from first script
#     we cannot access variables and functions declared in other script directly 
#     PID will be different for caller and calling scripts
# if we create using case2:
#     no need to give execute permission to any of the script
#     we can access variables and functions of calling script from caller directly
#     PID will be same for both caller and calling scripts