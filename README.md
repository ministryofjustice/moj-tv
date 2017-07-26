## MOJ TV ##

### Introduction ###

* This repository contains details on how to set up LAA / MOJ TV
* Version 1.0
* This code has been simplified from the original LAA TV to include only essentials for basic digital signage

### How do I get set up? ###

### Build a Pi ###
This should be installed on a Rasberry Pi 2 or 3, this is untested with Pi Zero but in theory should work.
Recommended SD card size - 8GB minimum.

### Install OS ###
MoJ TV runs off of a standard Raspian install.  If you have purchased a Pi kit it is likely the SD card will
have NOOBS pre installed, use this to install Raspian.  If not follow the instructions here:

https://www.raspberrypi.org/downloads/

### Install helper scripts ###
These scripts are designed to configure the Pi to start up and run the RiseVision software and display the signage.
It does various things such as hide the mouse pointer, set the background image, start up a wifi checker script etc.

To install:
Download this repository to the user home directory (usually the pi users).

Run build.sh - 
sudo ./install/build.sh install username PiID [noupdate]

username - normal system user, eg pi
PiID - the name of the pi, eg Pi_45
noupdate - skip OS update and upgrades (use if done already)

If install fails view log for errors then run build.sh uninstall to clean up and remove files.

At this point you can take an image of the SD card using a utility such as
Win32DiskImager and clone the SD card to other Pis

### Rise Vision ###
Rise Vision is a freemium cloud digital signage provider.  Once the build is complete when you restart the Pi it will
prompt you for your RiseVision Display ID.

To configure RiseVision - 
Go to https://www.risevision.com and sign up with a gmail account.
Follow RiseVision guidance on how to set up Presentations, Schedules and Displays.

To avoid charges uploading content, you can host your content remotely and display via url.  To do this with slides
you can embed Google slides into placeholders.

### Support ###

* Developer - david.elliott@justice.gov.uk
* Business Analyst gregory.cole@justice.gov.uk

For more version config and version information see MOJ_PI_README
