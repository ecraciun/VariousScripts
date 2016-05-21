#!/bin/bash

# Path to files
logfile="/home/pi/Scripts/crontab/dnsUpdate.log"
ipfile="/home/pi/Scripts/crontab/myip.txt"

# DynDns api url
dynDnsUrl="https://www.duckdns.org/update?domains=[DOMAIN]&token=[TOKEN]"

# Get current IP from web service
echo "[$(date)] Getting current ip..." >> "$logfile"
currentIP=$(curl -s https://api.ipify.org?format=text)
currentIP=$(echo -n "$currentIP")
echo "[$(date)] Current ip is: $currentIP" >> "$logfile"


function updateDnsEntry()
{
	local attempts="1"
	local responseSuccessful=false

	while [ "$attempts" -lt 6 -a "$responseSuccessful" = false ];
	do
		local response=$(curl -s "$dynDnsUrl")
		echo "[$(date)] Server response is (attempt $attempts): $response" >> "$logfile"
		
		if [ "$response" == "OK" ];
		then
			echo -n "$currentIP" > "$ipfile"
			responseSuccessful=true
		else
			echo "[$(date)] Server response was not OK, not saving new ip to file" >> "$logfile"
			attempts=$[$attempts+1]
		fi				
	done	
}

# Check if there is a previous IP saved in a local file
if [ -f "$ipfile" ];
then
	line=$(cat "$ipfile")
	echo "[$(date)] IP from file is: $line" >> "$logfile"

	# Check if current IP is the same as the saved one
	if [ "$currentIP" != "$line" ];
	then
		echo "[$(date)] Previous entry does not match current ip. Updating DNS entry..." >> "$logfile"
		
		updateDnsEntry
	else
		echo "[$(date)] Previous entry matches current ip" >> "$logfile"
	fi
else
	echo "[$(date)] No previous IP file found. Creating it and updating DNS entry..." >> "$logfile"
	
	updateDnsEntry
fi

echo "" >> "$logfile"
