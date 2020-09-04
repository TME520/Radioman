#!/bin/bash

while true
do
	echo "Status report." > /tmp/tts
	echo "Battery." >> /tmp/tts
	acpi -b | awk '{print $3" "$4}' >> /tmp/tts &&  sed -i 's/,/./' /tmp/tts
	echo "" >> /tmp/tts
	echo "Temperature." >> /tmp/tts
	acpi -t | awk '{print $1" "$2" "$3}' >> /tmp/tts && sed -i 's/,/./' /tmp/tts
	KISMETCOUNT=$(ps -ef|grep -w [k]ismet|wc -l)
	echo "" >> /tmp/tts
	echo "Kismet count: "$KISMETCOUNT >> /tmp/tts
	echo "" >> /tmp/tts
	if [ "$KISMETCOUNT" == "0" ]
	then
		echo "Warning: Kismet is not running. I repeat, kismet is not running." >> /tmp/tts
	else
		echo "All clear." >> /tmp/tts
	fi
	festival --tts /tmp/tts
	sleep 10 
	mpg123 ./front-desk-bells-daniel_simon.mp3
	sleep 10
done

exit 0
