#!/bin/sh
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/home/pi:/bin"
#Risevision shorcut copy script
#
#Instructions
#
#Run this script to copy the Rise desktop shortcut to the autostart folder.
#This is required when RiseVision updates the chrome app and the the link changes.
#The update should copy the new link to the desktop but won't copy it to the autostart folder.
#Must run as sudo
#Author: D. Elliott
#
#Version History
#1.0 Initial Version
#1.1 Amended to take latest shortcut from application list in startup menu
#1.2 Generalised for MOJTV
###########set variables###########
#set user vars

props=./moj_tv.prop

if [ -e "$props" ]; then
	piuser=$(grep -i 'piuser' $props  | cut -f2 -d'=')
	userhome=$(grep -i 'userhome' $props  | cut -f2 -d'=')
else
	userhome="/home/pi"
	piuser="pi"
fi

#echo "$userhome"
#echo "$piuser"

#full path to download folder
downloads='${userhome}/Downloads/'

#set Pi ID file
piidfile="${userhome}/moj_tv_files/pi-id.txt"

#log location
laalog="${userhome}/moj_tv_files/MOJTV.log"

#program name for error handling
PROGNAME=$(basename $0)

#load in Pi ID
read piid < $piidfile


#########Error handling#################
#use     2>&1 | tee -a $laalog    
#after none critical commands, this will give the error in the log but not exit
#
#use     || error_exit "Line $LINENO: Custom error message!Exiting"
#after critcal error which require the program to exit
#

#Exit on error function
error_exit()
{
	echo "$(date) - ${PROGNAME}: ${1:-"Unknown Error"}" 2>&1 | tee -a $laalog
	echo "shortcutcp.sh failed: $piid info:${PROGNAME}:${1:-"Unknown Error"}"  | mail -s "Failed shortcutcp $piid" laa.pi.alert@gmail.com
	exit 1
}

#####script start#####
echo "$(date) - cp shortcut starting" | tee -a $laalog

#remove existing startup file
rm ${userhome}/.config/autostart/chrome*.desktop || error_exit "Unable to remove shortcut!Exiting"

#copy latest start rise shortcut from applications menu
cp $(ls ${userhome}/.local/share/applications/chrome-* -1t | head -1) ${HOME}/.config/autostart || error_exit "Unable to copy shortcut!Exiting!"

#ensure executable
chmod 777 ${userhome}/.config/autostart/chrome*.desktop

echo "$(date) - cp shortcut complete" | tee -a $laalog
