#!/bin/bash

source ./radioman.conf

while true
do

	clear

	echo -n "💙"
	# Refreshing data
	ICONDISK="❓"
	ICONCPU="❓"
	ICONTEMP="❓"
	ICONRAM="❓"
	ICONBAT="❓"
	ICONGPS="❓"
	ICONWIFI="❓"
        ICONBT="❓"
	ICONKISMET="❓"
	ICONGEN="❓"
	PBCOUNT=0
	KISMETSRCCNT=0
	echo -n "💙"
	FREERAM=$(free -mt | tail -1 | awk '{print $4}')
	if [ $FREERAM -lt "512" ]
	then
		ICONRAM="⚠️"
	else
		ICONRAM="✅"
	fi
	echo -n "💙"
	CPUUSAGE=$(uptime | awk -F "," '{print $3}' | awk '{print $3}' | awk -F "." '{print $1}')
	if [ $CPUUSAGE -gt "3" ]
	then
		ICONCPU="⚠️"
	else
		ICONCPU="✅"
	fi
	echo -n "💙"
	FREEDISK=$(df -h | grep -w "/" | awk '{print $5}' | tr -d '%')
	if [ $FREEDISK -gt "75" ]
	then
		ICONDISK="⚠️"
	else
		ICONDISK="✅"
	fi
	echo -n "💙"
	if [ -f $KISMETCONF ]
	then
		KISMETSRCCNT=$(grep -c '^source=' $KISMETCONF)
		if [ $KISMETSRCCNT -gt 0 ]
		then
			grep '^source=' $KISMETCONF | grep '=wl' | awk -F '=' '{print $2}' | awk -F ':' '{print $1}' > /tmp/if2check
			grep '^source=' $KISMETCONF | grep '=hci' | awk -F '=' '{print $2}' | awk -F ':' '{print $1}' > /tmp/bt2check
		fi
	fi
	echo -n "💙"
	KISMETCOUNT=$(ps -ef|grep -w [k]ismet|grep -v sudo|wc -l)
	gpspipe -n 30 -r > /tmp/magoo
	SATINVIEW="Unknown"
	SATINVIEWCNT=$(grep -c GPGSV /tmp/magoo)
	echo -n "💙"
	if [ $SATINVIEWCNT -gt 0 ]
	then
		grep GPGSV /tmp/magoo > /tmp/magoo2
		SATINVIEW=$(tail -1 /tmp/magoo2 | awk -F ',' '{print $4}')
	fi
	SATFIXTYPE="Unknown"
	echo -n "💙"
	SATFIXCNT=$(grep -c GPGSA /tmp/magoo)
	if [ $SATFIXCNT -gt 0 ]
	then
		grep GPGSA /tmp/magoo > /tmp/magoo2
		SATFIX=$(tail -1 /tmp/magoo2 | awk -F ',' '{print $3}')
		if [ $SATFIX -eq 1 ]
		then
			SATFIXTYPE="No fix."
		elif [ $SATFIX -eq 2 ]
		then
			SATFIXTYPE="2D fix."
		elif [ $SATFIX -eq 3 ]
		then
			SATFIXTYPE="3D fix."
		fi
	fi

	# Preparing spoken output
	echo -n "💙"
	# Metrics
	echo "Status report." > /tmp/tts
	echo "" >> /tmp/tts
	echo "GPS information." >> /tmp/tts
	echo "Number of GPS satellites in view: "$SATINVIEW". GPS fix type is "$SATFIXTYPE"." >> /tmp/tts
	echo "Kismet count. "$KISMETCOUNT"." >> /tmp/tts
	echo "" >> /tmp/tts

	# Counting issues
	echo -n "💙"
	if [ $SATFIXCNT -eq 0 ]
	then
		echo "Warning: No GPS location is being recorded." >> /tmp/tts 
		ICONGPS="❌"
		((PBCOUNT++))
	else
		ICONGPS="✅"
	fi
	echo -n "💙"
	if [ $SATINVIEWCNT -eq 0 ]
	then
		echo "Warning: No GPS satellites in view." >> /tmp/tts 
		ICONGPS="❌"
		((PBCOUNT++))
	else
		ICONGPS="✅"
	fi
	echo -n "💙"
	if [ $KISMETCOUNT -eq 0 ]
	then
		echo "Warning: Kismet is not running. I repeat, kismet is not running." >> /tmp/tts
		ICONKISMET="❌"
		((PBCOUNT++))
	else
		ICONKISMET="✅"
	fi
	echo -n "💙"
	if [ $KISMETSRCCNT -eq 0 ]
	then
		echo "Warning: No sources configured in Kismet. Wireless networks are not getting mapped." >> /tmp/tts
		ICONKISMET="❌"
		((PBCOUNT++))
	else
                echo -n "💙"
		ICONWIFI="✅"
		while read wifi_interface
		do
			WIFIIFSTATUS=$(iwconfig $wifi_interface 2>&1 | grep -c "No such device")
			if [ $WIFIIFSTATUS -gt 0 ]
			then
				echo "Warning: wireless interface $wifi_interface DOWN." >> /tmp/tts
				ICONWIFI="❌"
				((PBCOUNT++))
			fi
		done < /tmp/if2check
                WIFIIFCNT=$(wc -l /tmp/if2check  | awk '{print $1}')
                echo "Number of wifi interfaces: $WIFIIFCNT" >> /tmp/tts
                echo -n "💙"
                ICONBT="✅"
                while read bt_interface
                do
                        BTIFSTATUS=$(hciconfig $bt_interface 2>&1 | grep -c "No such device")
                        if [ $BTIFSTATUS -gt 0 ]
                        then
				echo "Warning: bluetooth interface $bt_interface DOWN." >> /tmp/tts
				ICONBT="❌"
				((PBCOUNT++))
                        fi
                done < /tmp/bt2check
	fi

	if [ $PBCOUNT -eq 0 ]
	then
		echo "End of report. All clear." >> /tmp/tts
		ICONGEN="✅"
	elif [ $PBCOUNT -eq 1 ]
	then
		echo "" >> /tmp/tts
		echo $PBCOUNT" issue detected." >> /tmp/tts
		ICONGEN="⚠️"
	else
		echo "" >> /tmp/tts
		echo $PBCOUNT" issues detected." >> /tmp/tts
		ICONGEN="⛔️"
	fi

	# Preparing console output
	echo ""
	echo ""
	echo $ICONDISK"  Disk space"
	echo $ICONCPU"  CPU usage"
	echo $ICONTEMP"  Temperature"
	echo $ICONRAM"  RAM"
	echo $ICONBAT"  Battery"
	echo $ICONGPS"  GPS"
	echo $ICONWIFI"  WIFI"
	echo $ICONBT"  BLUETOOTH"
	echo $ICONKISMET"  Kismet"
	echo ""
	echo $ICONGEN"  General status"

	# DEBUG
	echo -e "\033[0;34m"
	echo "[DEBUG] KISMETCOUNT="$KISMETCOUNT
	echo "[DEBUG] SATINVIEW="$SATINVIEW
	echo "[DEBUG] SATFIX="$SATFIX
	echo "[DEBUG] SATFIXTYPE="$SATFIXTYPE
	echo "[DEBUG] SATFIXCNT="$SATFIXCNT
	echo "[DEBUG] KISMETSRCCNT="$KISMETSRCCNT
	echo -e "\033[0m"

	# Reading data out loud
	festival -b --tts /tmp/tts
	sleep 10 
	mpg123 -q ./front-desk-bells-daniel_simon.mp3
	sleep 10
done

exit 0
