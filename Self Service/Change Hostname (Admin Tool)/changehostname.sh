#!/bin/sh
########################################################################
# Created By: Ross Derewianko Ping Identity Corporation
# Creation Date: Febuary, 2015 
# Last modified: March 15, 2016
# Brief Description: Changes machine hostname
########################################################################

#check for cocoa dialogue & if not install it
if [ -d "<location of Cocoa Dialogue.app>" ]; then
	CD="<location of Cocoa Dialogue>/Contents/MacOS/CocoaDialog"
else
	echo "CocoaDialog.app not found installing" 
	/usr/sbin/jamf policy -trigger cocoa
	CD="<location of Cocoa Dialogue>/Contents/MacOS/CocoaDialog"
fi

########################################################################
# Functions
#######################################################################

#asks for the new hostname & then call in the cleaner!
function cdprompt() {
	hostname=`"$CD" standard-inputbox --title "What is the new hostname" --informative-text "Please enter a hostname using the following format. 
	-r for retina and -a for air"`

	if [ "$hostname" == "2" ]; then
		echo "user cancelled"
		exit 1
	fi
	cleanhostname
}

#cleans the first two characters out (cocoaDialogue adds a 1 \n to the string value which we don't need.)
function cleanhostname() {
	hostname=${hostname:2}
}

#checks for a blank hostname, and if its blank prompt agian 

function checkforblank() {
	while [[ -z $hostname && {$hostname+1} ]]
	do
		cdprompt
	done
}

function sethostname() {
	scutil --set HostName $hostname
	scutil --set ComputerName $hostname
	scutil --set LocalHostName $hostname
}

########################################################################
# Script
########################################################################
cdprompt
checkforblank
sethostname
