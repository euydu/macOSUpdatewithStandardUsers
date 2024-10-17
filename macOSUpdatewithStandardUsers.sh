#!/bin/bash
# Created by Emre Uydu - System Engineer
# emreuydu@gmail.com
# Contact to me for more info
##########################################################################################################
# D E T A I L S
#
# Install macOS update with Standard accounts on Silicon CPU
# The script grants temporary admin rights to standard users for 30 minutes / or until a restart to perform updates.
# After the device is restarted, the user's admin rights are automatically deleted.
#
##########################################################################################################
#determine current user
currentuser=$(who | awk '/console/{print $1}')
#Make Admin Current USer until next restart - max 30 minutes. 
sudo defaults write /Library/LaunchDaemons/removeAdmin.plist Label -string "removeAdmin"
sudo defaults write /Library/LaunchDaemons/removeAdmin.plist ProgramArguments -array -string /bin/sh -string "/Library/Application Support/JAMF/removeAdminRights.sh"
sudo defaults write /Library/LaunchDaemons/removeAdmin.plist StartInterval -integer 3600
sudo defaults write /Library/LaunchDaemons/removeAdmin.plist RunAtLoad -boolean yes
sudo chown root:wheel /Library/LaunchDaemons/removeAdmin.plist
sudo chmod 644 /Library/LaunchDaemons/removeAdmin.plist
launchctl load /Library/LaunchDaemons/removeAdmin.plist
sleep 10
if [ ! -d /private/var/userToRemove ]; then
	mkdir /private/var/userToRemove
	echo $currentuser >> /private/var/userToRemove/user
else
	echo $currentuser >> /private/var/userToRemove/user
fi
/usr/sbin/dseditgroup -o edit -a $currentuser -t user admin
cat << 'EOF' > /Library/Application\ Support/JAMF/removeAdminRights.sh
if [[ -f /private/var/userToRemove/user ]]; then
	userToRemove=$(cat /private/var/userToRemove/user)
	echo "Removing $userToRemove's admin privileges"
	/usr/sbin/dseditgroup -o edit -d $userToRemove -t user admin
	rm -f /private/var/userToRemove/user
	launchctl unload /Library/LaunchDaemons/removeAdmin.plist
	rm /Library/LaunchDaemons/removeAdmin.plist
	log collect --last 60m --output /private/var/userToRemove/$userToRemove.logarchive
fi
EOF
sudo authchanger -reset -jamfconnect #Reset JAMF Connect in TMP folder to avoid login issues after auto reboot. 
#Request Password
Password=$(osascript << EOF
text returned of (display dialog "Enter your password" default answer "" buttons {"OK"} default button 1)
EOF
)
#perform update
echo $CurrentPassword | sudo softwareupdate -iaR