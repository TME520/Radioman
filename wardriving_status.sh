#!/bin/bash

while true
do
	# Refreshing data
	PBCOUNT=0
	BATSTAT=$(acpi -b | awk '{print $3}' | tr -d ',')
	KISMETSRCCNT=$(grep -c '^source=' /etc/kismet/kismet.conf)
	if [ $KISMETSRCCNT -gt 0 ]
	then
		grep '^source=' /etc/kismet/kismet.conf | awk -F '=' '{print $2}' | awk -F ':' '{print $1}' > /tmp/if2check
	fi
	BATSTAT=$(acpi -b | awk '{print $3}' | tr -d ',')
	BATCHARGE=$(acpi -b | awk '{print $4}' | tr -d ',' | tr -d '%')
	TEMP=$(acpi -t | awk '{print $1" "$2" "$3}' | tr [,] [.])
	KISMETCOUNT=$(ps -ef|grep -w [k]ismet|wc -l)
	gpspipe -n 30 -r -x 15 > /tmp/magoo
	SATINVIEW="Unknown"
	SATINVIEWCNT=$(grep -c GPGSV /tmp/magoo)
	if [ $SATINVIEWCNT -gt 0 ]
	then
		grep GPGSV /tmp/magoo > /tmp/magoo2
		SATINVIEW=$(tail -1 /tmp/magoo2 | awk -F ',' '{print $4}')
	fi
	SATFIXTYPE="Unknown"
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

	# DEBUG
	echo "[DEBUG] BATSTAT="$BATSTAT
	echo "[DEBUG] BATCHARGE="$BATCHARGE
	echo "[DEBUG] TEMP="$TEMP
	echo "[DEBUG] KISMETCOUNT="$KISMETCOUNT
	echo "[DEBUG] SATINVIEW="$SATINVIEW
	echo "[DEBUG] SATFIX="$SATFIX
	echo "[DEBUG] SATFIXTYPE="$SATFIXTYPE
	echo "[DEBUG] SATFIXCNT="$SATFIXCNT
	echo "[DEBUG] KISMETSRCCNT="$KISMETSRCCNT

	# Preparing output
	# Metrics
	echo "Status report." > /tmp/tts
	echo "Battery." >> /tmp/tts
	echo $BATSTAT"." >> /tmp/tts
	echo $BATCHARGE"%." >> /tmp/tts
	echo "" >> /tmp/tts
	echo "Temperature. "$TEMP >> /tmp/tts
	echo "" >> /tmp/tts
	echo "GPS information." >> /tmp/tts
	echo "Number of GPS satellites in view: "$SATINVIEW". GPS fix type is "$SATFIXTYPE"." >> /tmp/tts
	echo "Kismet count. "$KISMETCOUNT"." >> /tmp/tts
	echo "" >> /tmp/tts

	# Announcing issues
	if [ $BATCHARGE -lt 11 ]
	then
		echo "Warning: Battery is low." >> /tmp/tts
		((PBCOUNT++))
	fi
	if [ $SATFIXCNT -eq 0 ]
	then
		echo "Warning: No GPS location is being recorded." >> /tmp/tts 
		((PBCOUNT++))
	fi
	if [ $SATINVIEWCNT -eq 0 ]
	then
		echo "Warning: No GPS satellites in view." >> /tmp/tts 
		((PBCOUNT++))
	fi
	if [ $KISMETCOUNT -eq 0 ]
	then
		echo "Warning: Kismet is not running. I repeat, kismet is not running." >> /tmp/tts
		((PBCOUNT++))
	fi
	if [ $KISMETSRCCNT -eq 0 ]
	then
		echo "Warning: No sources configured in Kismet. Wireless networks are not getting mapped." >> /tmp/tts
		((PBCOUNT++))
	else
		while read wifi_interface
		do
			WIFIIFSTATUS=$(iwconfig $wifi_interface 2>&1 | grep -c "No such device")
			echo "WIFIIFSTATUS="$WIFIIFSTATUS
			if [ $WIFIIFSTATUS -gt 0 ]
			then
				echo "Warning: wireless interface DOWN." >> /tmp/tts
				((PBCOUNT++))
			fi
		done < /tmp/if2check
	fi

	if [ $PBCOUNT -eq 0 ]
	then
		echo "End of report. All clear." >> /tmp/tts
	elif [ $PBCOUNT -eq 1 ]
	then
		echo "End of report. "$PBCOUNT" issue detected." >> /tmp/tts
	else
		echo "End of report. "$PBCOUNT" issues detected." >> /tmp/tts
	fi

	# Reading data out loud
	festival --tts /tmp/tts
	sleep 10 
	mpg123 ./front-desk-bells-daniel_simon.mp3
	sleep 10
done

exit 0
