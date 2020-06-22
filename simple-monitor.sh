#!/bin/bash

HOSTS="10.0.0.10"
COUNT=5
checkperiod=60 #seconds
current_status_down_count=/etc/device_link/down/down.txt
current_status_up_count=/etc/device_link/up/up.txt
#touch current_status_down_count
#touch current_status_up_count
cmt=0
while true
do
    sleep $checkperiod
    count=$(ping -c $COUNT $HOSTS | grep 'received' | awk -F',' '{ print $2 }' | awk '{ print $1 }')
    if [ $count -eq 0 ]; then
        cmt+=1
	# 100% failed
        if [ ! -f $current_status_down_count ] && [cmt == 2 ]; then 
        	echo "Device/Link/backhaul down  at $(date)" | mail -s "Device/Link/backhaul Down $(date)" xyz@gmail.com
        	echo "Host : $myHost is down (ping failed) at $(date)"
        	touch $current_status_down_count
		echo "0" > $current_status_down_count
		cmt=0
        	if [ $current_status_up_count ] ; then 
	 		rm $current_status_up_count
		fi
        fi
    
    elif [ $count -ne 0 ]; then
        if [ ! -f $current_status_up_count ] ; then 
    		echo "Device/Link/backhaul back online at $(date) " |  mail -s "Device/Link/backhaul back up $(date)" xyz@gmail.com
    		touch $current_status_up_count
		echo "0" > $current_status_up_count
    		if [ $current_status_down_count ] ; then
			rm $current_status_down_count
		fi
        fi
    fi
done
