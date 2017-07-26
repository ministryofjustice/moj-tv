#!/bin/sh
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/home/pi:/bin"
#######################################################
#
#Script to check network status and reconnect if down
#
#Author D. Elliott
#Please see further configuration instructions at the bottom of the script
#Version History
#1.0 - Initial version
#1.1 - Added check to reboot Pi if no connection for 60 reconnect attempts (1 hour if ran every minute)
#    - Added check for wired connection
#    - Added option to amend file paths and max reconnect attempts
#1.2 - Changed log output location to LAATV.log
#    - Moved count file to laa_files
#1.3 - Generalised for MOJ TV
########################################################

#options

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

#set count file path
countfile="${userhome}/moj_tv_files/count.txt"

#set log file path
logfile="${userhome}/moj_tv_files/MOJTV.log"

#set attempts before reboot
attempts=60

#load count from file
read count < $countfile

#check if wireless connection
if ifconfig wlan0 | grep -q "inet addr:" ; then
	echo "0" > $countfile
	exit 0

#check if wired connection
elif ethtool eth0 | grep -q "Link detected: yes" ; then
	echo "0" > $countfile
	exit 0

#otherwise attempt reconnect
else
	ifdown --force wlan0
	sleep 10
	ifup --force wlan0
	count=$((count+1))	
	echo "$(date) - Wifi reconnect attempted - $count" >> $logfile
	echo $count > $countfile
	
	if [ "$count" -gt "$attempts" ]
	then
		echo "0" > $countfile
		reboot
	fi
fi

############################################################
#
#Configuration settings to run the script every minute.
#
#Ensure script is executable:
#sudo chmod +x wifi-check.sh
#
#Add to crontab
#sudo crontab -e
#Add the line:
#* * * * * /home/pi/moj_tv_files/wifi-check.sh
#
#Add the following entry to /etc/logrotate.conf
#This will rotate the wifi-check log file to ensure it doesn't get to big
#
#/home/pi/moj_tv_files/wifi-check.log {
#	size 5M
#	rotate 3
# }
#
#This script is written to be saved on the desktop for ease of use
#If you change the location it is saved please adjust file and path locations accordingly
#
###########################################################3
