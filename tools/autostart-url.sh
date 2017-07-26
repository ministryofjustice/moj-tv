#!/bin/sh
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/home/linaro/Desktop:/bin"

#######################################################
#
#Script to update the autostart to show a url
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

#set file path to auto start link
file="/home/linaro/.config/autostart/chrome-mfpgpdablffhbfofnhlpgmokokbahooi-Default.desktop"

#text for auto start link
cat > $file <<EOL
#!/usr/bin/env xdg-open
[Desktop Entry]
Version=1.0
Terminal=false
Type=Application
Name=Launch LAA TV
Exec=/usr/bin/chromium-browser --profile-directory=Default --app-id=mfpgpdablffhbfofnhlpgmokokbahooi
Icon=chrome-mfpgpdablffhbfofnhlpgmokokbahooi-Default
StartupWMClass=crx_mfpgpdablffhbfofnhlpgmokokbahooi


#[Desktop Entry]
#Version=1.0
#Name=LAA TV Slides
#GenericName=LAA TV Slides
#Comment=LAA LAA TV Slides
#Exec=chromium-browser %U --kiosk https://docs.google.com/presentation/d/10fhnOy1O-7FLAfPWiF9bt6ys8Z6YMVAmxusHTghvj3o/embed?start=true&loop=true&delayms=10000&slide=id.gc32023c71_5_0
#Terminal=false
#X-MultipleArgs=false
#Type=Application
#Icon=ksysguard
#Categories=Network;WebBrowser;
#MimeType=text/html;text/xml;application/xhtml_xml;x-scheme-handler/http;x-scheme-handler/https;
#StartupWMClass=Chromium-browser
#StartupNotify=true

EOL


