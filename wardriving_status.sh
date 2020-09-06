#!/bin/bash

while true
do
	# Refreshing data
	PBCOUNT=0
	BATSTAT=$(acpi -b | awk '{print $3}' | tr -d ',')
	BATCHARGE=$(acpi -b | awk '{print $4}' | tr -d ',' | tr -d '%')
	TEMP=$(acpi -t | awk '{print $1" "$2" "$3}' | tr [,] [.])
	KISMETCOUNT=$(ps -ef|grep -w [k]ismet|wc -l)
	gpspipe -n 30 -r > /tmp/magoo
	grep GPGSV /tmp/magoo > /tmp/magoo2
	SATINVIEW=$(tail -1 /tmp/magoo2 | awk -F ',' '{print $4}')
	grep GPGSA /tmp/magoo > /tmp/magoo2
	SATFIX=$(tail -1 /tmp/magoo2 | awk -F ',' '{print $3}')
	SATFIXTYPE="Unknown"
	if [ $SATFIX -eq 1 ]
	then
		SATFIXTYPE="No fix. Warning: no GPS location currently available."
		((PBCOUNT++))
	elif [ $SATFIX -eq 2 ]
	then
		SATFIXTYPE="2D fix."
	elif [ $SATFIX -eq 3 ]
	then
		SATFIXTYPE="3D fix."
	fi

	# DEBUG
	echo "[DEBUG] BATSTAT="$BATSTAT
	echo "[DEBUG] BATCHARGE="$BATCHARGE
	echo "[DEBUG] TEMP="$TEMP
	echo "[DEBUG] KISMETCOUNT="$KISMETCOUNT
	echo "[DEBUG] SATINVIEW="$SATINVIEW
	echo "[DEBUG] SATFIX="$SATFIX
	echo "[DEBUG] SATFIXTYPE="$SATFIXTYPE

	# Preparing output
	echo "Status report." > /tmp/tts
	echo "Battery." >> /tmp/tts
	echo $BATSTAT"." >> /tmp/tts
	echo $BATCHARGE"%." >> /tmp/tts
	echo "" >> /tmp/tts
	if [ $BATCHARGE -lt 11 ]
	then
		echo "Warning: Battery is low." >> /tmp/tts
		((PBCOUNT++))
	fi
	echo "Temperature. "$TEMP >> /tmp/tts
	echo "" >> /tmp/tts
	echo "GPS information." >> /tmp/tts
	echo $SATINVIEW" GPS satellites in view. GPS fix type is "$SATFIXTYPE"." >> /tmp/tts
	echo "Kismet count. "$KISMETCOUNT"." >> /tmp/tts
	echo "" >> /tmp/tts
	if [ "$KISMETCOUNT" == "0" ]
	then
		echo "Warning: Kismet is not running. I repeat, kismet is not running." >> /tmp/tts
		((PBCOUNT++))
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
