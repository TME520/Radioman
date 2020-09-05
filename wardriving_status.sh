#!/bin/bash

while true
do
	# Refreshing data
	BATSTAT=$(acpi -b | awk '{print $3}' | tr -d ',')
	BATCHARGE=$(acpi -b | awk '{print $4}' | tr -d ',' | tr -d '%')
	TEMP=$(acpi -t | awk '{print $1" "$2" "$3}' | tr [,] [.])
	KISMETCOUNT=$(ps -ef|grep -w [k]ismet|wc -l)
	(echo "open 127.0.0.1 2947" && sleep 2 && echo "?POLL;") | telnet > /tmp/magoo
	grep active /tmp/magoo > /tmp/magoo2
	if [ $? -eq 0 ]
	then
		GPSFIX=$(cat /tmp/magoo2 | awk -F ',' '{print $3}' | awk -F ':' '{print $2}')
	else
		GPSFIX="Failed to get GPS status."
	fi

	# DEBUG
	echo "[DEBUG] BATSTAT="$BATSTAT
	echo "[DEBUG] BATCHARGE="$BATCHARGE
	echo "[DEBUG] TEMP="$TEMP
	echo "[DEBUG] KISMETCOUNT="$KISMETCOUNT
	echo "[DEBUG] GPSFIX="$GPSFIX

	# Preparing output
	echo "Status report." > /tmp/tts
	echo "Battery." >> /tmp/tts
	echo $BATSTAT"." >> /tmp/tts
	echo $BATCHARGE"%." >> /tmp/tts
	echo "" >> /tmp/tts
	if [ $BATCHARGE -lt 11 ]
	then
		echo "Warning: Battery is low." >> /tmp/tts
	elif [ $BATCHARGE -lt 666 ]
	then
		echo "Warning: Battery is very low. System will shutdown shortly." >> /tmp/tts
	fi
	echo "Temperature. "$TEMP >> /tmp/tts
	echo "" >> /tmp/tts
	echo "Active GPS sources." >> /tmp/tts
	echo $GPSFIX"." >> /tmp/tts
	echo "Kismet count. "$KISMETCOUNT"." >> /tmp/tts
	echo "" >> /tmp/tts
	if [ "$KISMETCOUNT" == "0" ]
	then
		echo "Warning: Kismet is not running. I repeat, kismet is not running." >> /tmp/tts
	else
		echo "All clear." >> /tmp/tts
	fi

	# Reading data out loud
	festival --tts /tmp/tts
	sleep 10 
	mpg123 ./front-desk-bells-daniel_simon.mp3
	sleep 10
done

exit 0
