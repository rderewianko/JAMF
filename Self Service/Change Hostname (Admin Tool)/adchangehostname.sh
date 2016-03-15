#!/bin/sh
#File Name: hostname.sh
########################################################################
# Created By: Ross Derewianko Ping Identity Corporation
# Creation Date: Febuary, 2015 
#“Lisa, if I’ve learned anything, it’s that life is just one crushing defeat after another until you just wish Flanders was dead.”*
# Last modified: March 2, 2016
# Brief Description: Changes machine hostname on a AD bound machine
########################################################################
#Statically Define Username if needed
# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO “domainpassword”
if [ "$4" != "" ] && [ "$domainjoinpass" == "" ]; then
	domainjoinpass=$4
fi
if [ "$5" != "" ] && [ "$domainjoinun" == "" ]; then
	domainjoinun=$5
fi

ou="OU=Mac,OU=Contoso Computers,Computers,DC=corp,DC=contoso,DC=com"
domain="corp.contoso.com"
adserver="locationtoanadserver"

########################################################################
# Functions
#######################################################################

function findjamfbinary() {

	jamf_binary=`/usr/bin/which jamf`

	if [[ "$jamf_binary" == "" ]] && [[ -e "/usr/sbin/jamf" ]] && [[ ! -e "/usr/local/bin/jamf" ]]; then
	   jamf_binary="/usr/sbin/jamf"
	elif [[ "$jamf_binary" == "" ]] && [[ ! -e "/usr/sbin/jamf" ]] && [[ -e "/usr/local/bin/jamf" ]]; then
	   jamf_binary="/usr/local/bin/jamf"
	elif [[ "$jamf_binary" == "" ]] && [[ -e "/usr/sbin/jamf" ]] && [[ -e "/usr/local/bin/jamf" ]]; then
	   jamf_binary="/usr/local/bin/jamf"
	fi

}

function checkCocoa() {

	#check for cocoa dialogue & if not install it
	if [ -e "/Applications/Utilities/cocoaDialog.app/Contents/Info.plist" ]; then
	
	echo "Cocoa installed"
	else
	echo "Cocoa not Installed"
	findjamfbinary
	$jamf_binary policy -event cocoa
	fi

	CD="/Applications/Utilities/cocoaDialog.app/Contents/MacOS/CocoaDialog"

}

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



function unbindfromad() { 
	echo "Unbiding from AD"
	dsconfigad -remove -force -u domainjoin -p "$domainjoinpass"
}

function bindtoad() {
	# Uses the hostname to determine the username
	user=`hostname | rev | cut -c 3- |rev`

	# Bind machine to the network
	dsconfigad -add "$domain" -ou "$ou" -username "$domainjoinun" -password "$domainjoinpass" -computer `scutil --get ComputerName` -mobile enable -mobileconfirm disable -localhome enable -useuncpath disable -shell /bin/bash -groups 'Support Level One'
#changed -add corp.pingidentity.com to "$domain"

	# Add the user as a local admin
	dscl . append /Groups/admin GroupMembership $user
}

function notify () {
	  /Applications/Utilities/yo.app/Contents/MacOS/yo -t "$1" -m -n "$2" -o "Okay"
}

function changehostname() {
ping -c 3 -o $adserver 1> /dev/null 2> /dev/null
# If the ping was successful, we're in range of the DC
if [[ $? == 0 ]]; then
    # Check the domain returned with dsconfigad
    domain=$( dsconfigad -show | awk '/Active Directory Domain/{print $NF}' )
    # If the domain is correct
    if [[ "$domain" == "$domain" ]]; then
        # Check the id of a user
        id -u domainjoin
        # If the check was successful...
        if [[ $? == 0 ]]; then
            echo "The Mac is bound to AD"
            unbindfromad
            sethostname
            bindtoad
            notify "Hostname Changed" "Please reboot to complete this process"
            exit 0
        else
            # If the check failed
            echo "The Mac is not bound to AD"
            sethostname
            notify "Hostname Changed" "Please reboot to complete this process"
            exit 0
        fi
    else
        # If the domain returned did not match our expectations
        echo "The Mac is not bound to domain"
        sethostname
        notify "Hostname Changed" "Please reboot to complete this process"
        exit 0
    fi
else
    # We can't see the DCs, so no way to properly check
    echo "Not in range of DC"
    notify "Hostname Not Changed" "Machine Can't Talk to AD"
    exit 1
fi
}

########################################################################
# Script
########################################################################
checkCocoa
cdprompt
checkforblank
changehostname

