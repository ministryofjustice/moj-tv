#!/bin/sh

#MOJ TV builder
#
#Instructions
#
#This script will make an initial pi for RiseVision and MOJ TV.
#
#
#Usage
#install piid - performs clean install
#uninstall - removes MOJ TV custom files, does not remove
#            applications or modifications to those applications
#Amend accordingly for required changes. Run as sudo.
#
#Author: D. Elliott
#
#Version History
#1.0 Initial Version
#1.1 Cleaned to removed unused content 
#1.2 
#1.3

#########Error handling#################
#use     2>&1 | tee -a $tvlog    
#after none critical commands, this will give the error in the log but not exit
#
#use     || error_exit "Line $LINENO: Custom error message!Exiting"
#after critcal error which require the program to exit
#

#Exit on error function
#replace with your email address if configuring email sending
error_exit()
{
	echo "$(date) - ${PROGNAME}: ${1:-"Unknown Error"}" 2>&1 | tee -a $tvlog
	echo "New install failed: $piid. Additional info:${PROGNAME}:${1:-"Unknown Error"}"  | mail -s "New Install Failed: $piid" <youremail>@gmail.com
	echo "Before attempting the install again run ./build.sh uninstall to clean up files."
	exit 1
}

clean_up()
{
	echo "Starting cleanup..."
	echo "Deleteing MOJ TV files"
	rm -r -f $moj_tv_files
	echo "Restoring /etc/X11/xinit/xinitrc"
	mv /etc/X11/xinit/xinitrc.bak /etc/X11/xinit/xinitrc
	echo "restoring /etc/kbd/config"
	sudo cp /etc/kbd/config.bak /etc/kbd/config
	echo "restoring /boot/config.txt"
	sudo mv /boot/config.txt.bak /boot/config.txt
	echo "Removing shortcuts"
	rm ${userhome}/.local/autostart/chrome-*.desktop 
	echo "Restoring log rotator"
	mv /etc/logrotate.conf.bak /etc/logrotate.conf
	echo "restoring Desktop background"
	mv ${userhome}/.config/pcmanfm/LXDE-pi/desktop-items-0.conf.bak ${userhome}/.config/pcmanfm/LXDE-pi/desktop-items-0.conf
	echo "restoring splash screen"
	mv /usr/share/plymouth/themes/pix/splash.png.bak /usr/share/plymouth/themes/pix/splash.png
	echo "Restoring Email config"
	mv /etc/ssmtp/ssmtp.conf.bak /etc/ssmtp/ssmtp.conf
	mv /etc/ssmtp/revaliases.bak /etc/ssmtp/revaliases
	echo "If Rise Vision is installed please uninstall now..."
	echo "Navigate to chrome://extensions"
	sudo -u ${piuser} chromium-browser 
	echo "Programs installed with apt have not been removed"
	echo "Modifications to system files have not been undone"
	echo "Clean up complete"
}

#####Start Script#####
clear
echo "********************************************************************"
echo "*                MOJ TV installation script                        *"
echo "*                                                                  *"
echo "* This script will install a MOJ TV to a Pi 2 or 3 running Raspian *"
echo "* For best results start with a clean install                      *"
echo "*                                                                  *"
echo "* Download project from git to your user home folder ~             *"
echo "*                                                                  *"
echo "* Version - 1.1                                                    *"
echo "* Author - David Elliott - LAA Digital                             *"
echo "*                                                                  *"
echo "* To quit this install at any point Ctrl + C                       *"
echo "*                                                                  *"
echo ""
echo "*           ****************Usage:*********************"
echo "*"
echo "* sudo buildlaatv.sh install username PiID [noupdate]"
echo "* sudo buildlaatv.sh uninstall username"
echo "*"
echo "* install - Install on Pi   ***  uninstall - Remove from Pi"
echo "* username - normal system user, eg pi, linaro."
echo "* PiID - the name of the pi, eg Pi_45"
echo "* noupdate - skip OS update and upgrades (use if done already)"
echo "*"
echo "* If install fails view log for errors then run build.sh uninstall"
echo "* to clean up and remove files"
echo "********************************************************************"
echo ""

###########load parameters and set variables##########
#set file name
if [ -n "$1" ]; then
	method="$1"
	if [ "$method" = "install" ] || [ "$method" = "uninstall" ]; then
		echo ""
	else
		echo "Invalid install or uninstall parameter"
		exit 1
	fi
else
	echo "No install or uninstall parameter"
	exit 1
fi

#set new user and home if present
if [ -n "$2" ]; then
	piuser="$2"
else
	echo "No user entered"
	exit 1
fi

#set home folder
userhome="/home/${piuser}"

# TV file location
moj_tv_files="${userhome}/moj_tv_files"

#run clean up if uninstall
if [ "$method" = "uninstall" ]
	then
	clean_up
	exit 0
fi

#set piid
if [ -n "$3" ]; then
	piid="$3"
else
	echo "No Pi ID entered"
	exit 1
fi

	
############set other variables###########

echo "userhome= ${userhome}"
echo "piuser = ${piuser}"

#full path to download folder
downloads="${userhome}/Downloads"
echo "downloads= ${downloads}"

#log location
tvlog="${userhome}/moj_tv_files/MOJTV.log"

#ip address
ipaddr=$(wget -qO- http://ipecho.net/plain)

#program name for error handling
PROGNAME=$(basename $0)

#load in Pi ID
#read piid < $piidfile

#check if id file exists, if it does options for fresh install
if [ -e "$piidfile" ]; then
	echo "This Pi has already been configured for MOJ TV"
	echo "Exit and run ./buildlaatv.sh uninstall to remove"
	echo "Exiting now"
	exit 1;
fi

#create MOJ TV folder
echo "Creating directory $moj_tv_files"
sudo -u ${piuser} mkdir -p $moj_tv_files || error_exit "Line $LINENO: Unable to create directory $moj_tv_files!Exiting"

#create properties file
sudo -u ${piuser} echo "#MoJ TV properties file" > $moj_tv_files/moj_tv.prop
sudo -u ${piuser} echo "piuser=${piuser}" >> $moj_tv_files/moj_tv.prop
sudo -u ${piuser} echo "userhome=${userhome}" >> $moj_tv_files/moj_tv.prop
sudo -u ${piuser} echo "piid=${piid}" >> $moj_tv_files/moj_tv.prop

#update system
if [ "$4" != "noupdate" ];then
	echo "Updating system" 2>&1 | tee -a $tvlog
	sudo apt-get update -y || error_exit "Line $LINENO: Unable to update!Exiting"
	sudo apt-get dist-upgrade -y || error_exit "Line $LINENO: Unable to upgrade!Exiting"
	echo "System update successfull" 2>&1 | tee -a $tvlog
fi

#install chromium and rpi-youtube - old method before in repo
#wget -qO - http://bintray.com/user/downloadSubjectPublicKey?username=bintray | sudo apt-key add -
#echo "deb http://dl.bintray.com/kusti8/chromium-rpi jessie main" | sudo tee -a /etc/apt/sources.list
#sudo apt-get update -y
#sudo apt-get install youtube-dl -y #(if not next line will prompt for it)
#sudo apt-get install chromium-browser rpi-youtube -y

#install chromium
echo "installing chromium-browser" 2>&1 | tee -a $tvlog
sudo apt-get install chromium-browser -y || error_exit "Line $LINENO: Unable to install chromium!Exiting"
echo "Successful" 2>&1 | tee -a $tvlog

#install unclutter to hide mouse
echo "installing unclutter" 2>&1 | tee -a $tvlog
sudo apt-get install unclutter -y || error_exit "Line $LINENO: Unable to install unclutter!Exiting"
echo "Successful" 2>&1 | tee -a $tvlog

#install ethtool for wifi script
echo "installing ethtool" 2>&1 | tee -a $tvlog
sudo apt-get install ethtool -y || error_exit "Line $LINENO: Unable to install ethtool!Exiting"
echo "Successful" 2>&1 | tee -a $tvlog

#install youtube downloader
echo "installing youtube-dl" 2>&1 | tee -a $tvlog
sudo apt-get install --yes youtube-dl || error_exit "Line $LINENO: Unable to install youtube-dl!Exiting"
echo "Successful" 2>&1 | tee -a $tvlog

#install email programs
echo "installing email" 2>&1 | tee -a $tvlog
sudo apt-get install --yes ssmtp || error_exit "Line $LINENO: Unable to install ssmtp!Exiting"
sudo apt-get install --yes mailutils || error_exit "Line $LINENO: Unable to install mailutils!Exiting"
echo "Successful" 2>&1 | tee -a $tvlog

#copy files to file location
echo "Copying files to ${moj_tv_files}" 2>&1 | tee -a $tvlog
sudo -u ${piuser} cp -r /home/${piuser}/moj_tv/* ${moj_tv_files} || error_exit "Line $LINENO: Unable to copy files to ${moj_tv_files}" 
echo "Successful"

#diable screen timeouts
#for current session only
echo "Disabling screen timeouts" 2>&1 | tee -a $tvlog
xset s off
xset s noblank
xset -dpms

#when session is started with startx
cp /etc/X11/xinit/xinitrc /etc/X11/xinit/xinitrc.bak
echo "#!/bin/sh" > /etc/X11/xinit/xinitrc
echo "xset s off         # don't activate screensaver" >> /etc/X11/xinit/xinitrc
echo "xset -dpms         # disable DPMS (Energy Star) features." >> /etc/X11/xinit/xinitrc
echo "xset s noblank     # don't blank the video device" >> /etc/X11/xinit/xinitrc
echo "" >> /etc/X11/xinit/xinitrc
echo "# /etc/X11/xinit/xinitrc" >> /etc/X11/xinit/xinitrc
echo "#" >> /etc/X11/xinit/xinitrc
echo "# global xinitrc file, used by all X sessions started by xinit (startx)" >> /etc/X11/xinit/xinitrc
echo "" >> /etc/X11/xinit/xinitrc
echo "# invoke global X session script" >> /etc/X11/xinit/xinitrc
echo ". /etc/X11/Xsession" >> /etc/X11/xinit/xinitrc

#for normal session start
cp /etc/xdg/lxsession/LXDE/autostart /etc/xdg/lxsession/LXDE/autostart.bak
echo "@lxpanel --profile LXDE" > /etc/xdg/lxsession/LXDE/autostart
echo "@pcmanfm --desktop --profile LXDE" >> /etc/xdg/lxsession/LXDE/autostart
echo "#@xscreensaver -no-splash" >> /etc/xdg/lxsession/LXDE/autostart
echo "@xset s off" >> /etc/xdg/lxsession/LXDE/autostart
echo "@xset -dpms" >> /etc/xdg/lxsession/LXDE/autostart
echo "@xset s noblank" >> /etc/xdg/lxsession/LXDE/autostart

#to stop timeout when on desktop
cp /etc/kbd/config /etc/kbd/config.bak 2>&1 | tee -a $tvlog
cp ${moj_tv_files}/config/config /etc/kbd/config 2>&1 | tee -a $tvlog 

#replace /boot/config.txt
echo "replace /boot/config.txt" 2>&1 | tee -a $tvlog
cp /boot/config.txt /boot/config.txt.bak 2>&1 | tee -a $tvlog
cp ${moj_tv_files}/config/config.txt /boot/config.txt 2>&1 | tee -a $tvlog

#backgroud images
echo "replace background image" 2>&1 | tee -a $tvlog
cp ${userhome}/.config/pcmanfm/LXDE-pi/desktop-items-0.conf ${userhome}/.config/pcmanfm/LXDE-pi/desktop-items-0.conf.bak 2>&1 | tee -a $tvlog   
cp ${moj_tv_files}/config/desktop-items-0.conf ${userhome}/.config/pcmanfm/LXDE-pi/desktop-items-0.conf 2>&1 | tee -a $tvlog

#replace splash screen
echo "replace spash screen" 2>&1 | tee -a $tvlog
cp /usr/share/plymouth/themes/pix/splash.png /usr/share/plymouth/themes/pix/splash.png.bak 2>&1 | tee -a $tvlog
cp ${moj_tv_files}/images/splash.png /usr/share/plymouth/themes/pix/splash.png 2>&1 | tee -a $tvlog

#install risevision
echo "Click install in the browser window which opens to install Rise Vision" 2>&1 | tee -a $tvlog
echo "Once installation has completed close the browser to continue the install script"
#sudo -u ${piuser} chromium-browser %U --incognito https://chrome.google.com/webstore/detail/rise-player/mfpgpdablffhbfofnhlpgmokokbahooi
sudo -u ${piuser} chromium-browser https://chrome.google.com/webstore/detail/rise-player/mfpgpdablffhbfofnhlpgmokokbahooi || error_exit "Line $LINENO: Unable to install RiseVision!Exiting"
echo "Continuing..." 2>&1 | tee -a $tvlog

#create autostart
echo "create autostart for rise" 2>&1 | tee -a $tvlog
mkdir ${userhome}/.config/autostart 2>&1 | tee -a $tvlog
cp ${userhome}/.local/share/applications/chrome-*.desktop ${userhome}/.config/autostart/ 2>&1 | tee -a $tvlog
chmod 777 ${userhome}/.config/autostart/chrome-*.desktop 2>&1 | tee -a $tvlog

#replace crontabs
sudo crontab ${moj_tv_files}/config/crontab || error_exit "Line $LINENO: Unable to install crontab!Exiting"
echo "$(date) - Crontab file updated" | tee -a $tvlog

#add user crontab
sudo -u ${piuser} crontab ${moj_tv_files}/config/user-crontab || error_exit "Line $LINENO: Unable to install user crontab!Exiting"
echo "$(date) - User Crontab file updated" | tee -a $tvlog

#add mojtv.log to log rotator
cp /etc/logrotate.conf /etc/logrotate.conf.bak
echo "${tvlog} {" >> /etc/logrotate.conf
echo "  size 5M" >> /etc/logrotate.conf
echo "  rotate 3" >> /etc/logrotate.conf
echo "}" >> /etc/logrotate.conf
echo "$(date) - MOJTV.log added to rotator" | tee -a $tvlog

#may need below...
#Set timezone
echo "Europe/London" | sudo tee /etc/timezone
sudo dpkg-reconfigure --frontend noninteractive tzdata
echo "$(date) - Timezone set to London" | tee -a $tvlog

#configure email
#This will allow scripts to send emails, add in your smtp server username and password
#email address and port below if needed.  Otherwise ignore.
echo "Configuring /etc/ssmtp/ssmtp.conf for email"
cp /etc/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf.bak
cat > /etc/ssmtp/ssmtp.conf <<EOL
#
# Config file for sSMTP sendmail
#
# The person who gets all mail for userids < 1000
# Make this empty to disable rewriting.
root=postmaster

# The place where the mail goes. The actual machine name is required no
# MX records are consulted. Commonly mailhosts are named mail.domain.com
mailhub=smtp.gmail.com:587

# Where will the mail seem to come from?
#rewriteDomain=

# The full hostname
hostname=raspberry

# Are users allowed to set their own From: address?
# YES - Allow the user to specify their own From: address
# NO - Use the system generated From: address
#FromLineOverride=YES

AuthUser=<username>
AuthPass=<password>
UseSTARTTLS=YES
AuthLogin=Yes

EOL

echo "Configuring /etc/ssmtp/revaliases for email"
cp /etc/ssmtp/revaliases /etc/ssmtp/revaliases.bak
cat > /etc/ssmtp/revaliases <<EOL
# sSMTP aliases
#
# Format:       local_account:outgoing_address:mailhub
#
# Example: root:your_login@your.domain:mailhub.your.domain[:port]
# where [:port] is an optional port number that defaults to 25.
root:youremail@gmail.com:smtp.gmail.com:587
linaro:youremail@gmail.com:smtp.gmail.com:587

EOL

sudo chmod 774 /etc/ssmtp/ssmtp.conf 2>&1 | tee -a $tvlog

#end of email config

echo "End of install see log for errors - ${tvlog}"
