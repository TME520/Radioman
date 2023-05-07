# Radioman: Wardriving companion
Keeps an eye on your wardriving setup and gear while you keep your eyes on the road

Made by a wardriver for wardrivers

## What it does

- Verbally gives you the status of your wardriving setup
- You can keep your eyes on the road without worrying about something going wrong
- Checks: Disk space, CPU & RAM usage, WiFi & Bluetooth interfaces status, GPS data and Kismet health

## Files

- `wardriving_status.sh`: It's the main script, the one you have to start in order to use this tool,

## Setup

1. `git clone https://github.com/TME520/wardriving.git`
2. `apt install acpi gpsd gpsd-clients festival mpg123 fonts-emojione`

## Usage

1. `cd ./wardriving`
2. `./wardriving_status.sh`

[ Ctrl + C ] to quit.

## Credits

- File `front-desk-bells-daniel_simon.mp3` sourced from [SoundBible.com](http://soundbible.com/)
