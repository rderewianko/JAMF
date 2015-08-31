#!/bin/sh
########################################################################
# Created By: Ross Derewianko
# For Ping Identity Corporation 2015
# Creation Date: August 29, 2015
# Last modified: August 31, 2015
# Brief Description: Find out if VM's are running and suspends them
########################################################################

########################################################################
# Script
########################################################################

vm=`/Applications/VMware\ Fusion.app/Contents/Library/vmrun list`
vmsRunning=`echo "$vm" | tail -n +2`

#find if there are vm's running, and if there are suspend them.
if [[ "$vm" == "Total running VMs: 0" ]]; then
	echo "no vm's running"
else

#debug
#	echo "i'mma gonna suspend sine vm's"
	vmsRunning=`echo "$vm" | tail -n +2`	

	echo "$vmsRunning" | while read line ; do
		/Applications/VMware\ Fusion.app/Contents/Library/vmrun suspend "$line"
	done
#debug
#	echo "I Suspended: $vmsRunning"
fi

#kill vmwf, will do nothing if its not runing...
killall -KILL VMware\ Fusion

exit 0