#!/bin/sh
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/home/pi:/bin"

#######################################################
#
#Script to shut down chromium and start rise
#
#Author D. Elliott
#Please see further configuration instructions at the bottom of the script
#Version History
#1.0 - Initial version
#    - 
#    - 
#    - 
#    - 
#    - 
########################################################

#set display to locall pi so still works when running remotely
export DISPLAY=:0

#kill all existing chromium tasks
sudo pkill chromium-browse

#launch rise
nohup /usr/bin/chromium-browser --profile-directory=Default --app-id=mfpgpdablffhbfofnhlpgmokokbahooi &