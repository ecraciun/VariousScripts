#!/bin/bash


MAC=[MAC_ADDRESS]
Broadcast=[BRODCAST_OR_TARGET_IP]
PortNumber=9
echo -e $(echo $(printf 'f%.0s' {1..12}; printf "$(echo $MAC | sed 's/://g')%.0s" {1..16}) | sed -e 's/../\\x&/g') | nc -u  $Broadcast $PortNumber -v
