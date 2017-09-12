#!/bin/bash
RED='\033[0;31m'
Yellow='\033[1;33m'
NC='\033[0m'
Cyan='\033[0;36m'
DOUBLE_CHECK=1
COUNTER=7
SLEEP_TIME=15
DIG_DNS=$(dig +noall +answer +short google.com)

echo -e "Active$Cyan FIDELITY$NC Monitoring [${RED}+${NC}] \n"
while true
	do
	clear
	echo -e "Active$Cyan FIDELITY$NC Monitoring [${RED}+${NC}] \n"
	sleep $SLEEP_TIME
	VALUE=$(nmcli -t -f ssid dev wifi | awk '/xfinitywifi/ {print;exit}' )
	STATE=$(nmcli -t network connectivity)
		if [[ -z "$VALUE" && "$STATE" == "full" ]]; then
			clear
			echo -e "Xfinitywifi Is No Longer In The Area \n"
			echo -e	"$Cyan	   Goodbye$NC [$Yellow!$NC] \n"
			sleep 3
			killall xterm &> /dev/null
			exit
		fi
   	avail=$(curl -s $DIG_DNS --ssl-no-revoke --compressed | tac | tac | awk 'NR==4{print; exit}')
   	WIFI_ID=$(iwgetid -r)
    if [[ -z "$avail" && "$WIFI_ID" == "xfinitywifi" ]]; then
		SCRIPT_CHECK=$(pgrep -f script1.sh)
		if [[ `expr $DOUBLE_CHECK % 5` -eq 0 ]]; then
			DOUBLE_CHECK=1
			echo -e "Internet$Yellow DISCONTINUITY$NC Detected [${RED}!${NC}] \n"
			sleep 1
			clear
			if [ -n "$SCRIPT_CHECK" ]; then
				for pid in $(pgrep -f script1); do kill -9 $pid; done
			fi
			sudo caffeinate xterm -geometry 70x20+0+0 -fa monospace -fs 8 -e './script1.sh'  & disown
			echo -e "Active$Cyan FIDELITY$NC Monitoring$Yellow ReSynced$NC [${RED}+${NC}]"
			sleep 3
			clear
			echo -e "Active$Cyan FIDELITY$NC Monitoring [${RED}+${NC}]"
			COUNTER=7
			sleep 45
		fi
		((DOUBLE_CHECK++))
		sleep 1
	fi
	if [ "$DOUBLE_CHECK" -gt 1 ]; then
		((COUNTER--))
		SLEEP_TIME=2
		if [[ "$COUNTER" -eq 0 && "$DOUBLE_CHECK" -ne 1 && `expr $DOUBLE_CHECK % 5` -ne 0 ]]; then 
			DOUBLE_CHECK=1
			COUNTER=7
			SLEEP_TIME=15
			sleep 30
		fi
	fi	
	clear
done
