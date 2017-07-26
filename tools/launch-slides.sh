#!/bin/sh
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/home/pi:/bin"

#######################################################
#
#Script to shut down Rise and to show a url
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
sleep 20

#launch slides
nohup chromium-browser %U --kiosk --incognito https://docs.google.com/presentation/d/10fhnOy1O-7FLAfPWiF9bt6ys8Z6YMVAmxusHTghvj3o/embed?start=true&loop=true&delayms=10000&slide=id.gc32023c71_5_0 &

