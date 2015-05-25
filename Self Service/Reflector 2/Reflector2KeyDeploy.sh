#!/bin/sh
########################################################################
# Created by: Ross Derewianko for Ping Identity Corporation
# Creation Date: May 2015
# Last modified: May 24, 2015
# Brief Description: Deploys License key for Reflector 2 put your key in - format in value 4
########################################################################
if [ "$4" != "" ] && [ "$key" == "" ]; then
  key=$4
fi

loggedinuser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

defaults write /Users/"$loggedinuser"/Library/Preferences/com.squirrels.Reflector-2.plist LicenseKey "$key"
chown "$loggedinuser":staff /Users/"$loggedinuser"/Library/Preferences/com.squirrels.Reflector-2.plist

exit 0