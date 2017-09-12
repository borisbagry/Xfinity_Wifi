#!/bin/bash 
Cyan='\033[0;36m'
RED='\033[0;31m'
Yellow='\033[1;33m'
NC='\033[0m'
CYCLECOUNT=0
SLOWPING=6
IFACE=$(nmcli -t -f DEVICE dev status | awk NR==1)
LAPTOP_KEY=$(xinput list --name-only | awk '/AT Translated/'; print)
ALT_KEY=$(xinput list --short | awk '/keyboard.*slave/ {s = substr($0,7,41); sub(/ *$/, "", s); print s; exit}')
WIFI_DRIVER=$(readlink /sys/class/net/wlan0/device/driver |rev| sed 's/\/.*//'|rev)
DIG_DNS=$(dig +noall +answer +short xfwweb.g.comcast.net)

while :; do echo
clear;

VIRGIN=$(pgrep script2.sh)

#network card reset block
service network-manager stop;
ifconfig $IFACE down;
macchanger -r -b $IFACE;
rfkill unblock all;
ifconfig $IFACE up;
service network-manager start;

#Mac File, Cookie Delete, Connection Check Block

macchanger -s $IFACE | awk -F " " '/Current/ {print $3}' > 'Mac.txt';

echo -e "\nWaiting for Connection [${Yellow}?${NC}] \n"

while true
	do
   	wget --spider $DIG_DNS  >> /dev/null 2>&1
    	if [[ $? -eq 0 ]]; then
			echo -e "Connected [${RED}!${NC}] \n"
			break
		else
			if ! (( $SLOWPING % 6)); then
				echo -e  "${Cyan}	Pinging Xfinity...${NC} \n"
			fi
		((SLOWPING++))
		sleep 0.5
    	fi
done

#DISABLE KEYBOARD WHILE LOGGER EXECUTES
if [ -z "$LAPTOP_KEY" ]; then 
	xinput set-prop "$ALT_KEY" "Device Enabled" 0
	sudo python logger.py > /dev/null
	xinput set-prop "$ALT_KEY" "Device Enabled" 1
else
	xinput set-prop "$LAPTOP_KEY" "Device Enabled" 0
	sudo python logger.py > /dev/null
	xinput set-prop "$LAPTOP_KEY" "Device Enabled" 1
fi
	
#CHECK IF SCRIPT2 INSTANCE IS ALREADY RUNNING
if [ -z "$VIRGIN" ];then
	sudo caffeinate xterm -geometry 70x5+0-0 -fa monospace -fs 8 -hold -e './script2.sh'  & disown
fi
	
clear

((CYCLECOUNT++))

echo -e "Entering Current Cycle at [${Cyan}$(date +%I:%M ) $(date +%p)${NC}] \n"
echo -e "Cycle Number: [${Yellow}$CYCLECOUNT${NC}] \n"
T_REF=$(date +%s -d +3543sec) 

SECS=$((59*60+2))
	while [ $SECS -gt 0 ]; do
		T_ACT=$(date +%s) 
		#Hibernating Device ReSync
		if [ $T_REF -lt $T_ACT ]; then
			echo -e "Time Is Out Of Sync Due to Hibernating Device [$RED !$NC ]"
			sleep 1.3
			SECS=0
		fi
   		echo -ne "Countdown Until Next Cycle [${Yellow}$SECS${NC}]\033[0K\r"
   		sleep 1
   		: $((SECS--))
	done
done
