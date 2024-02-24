#!/bin/bash

# Get Volume
volume=$(amixer get Master | grep 'Front Left:' | awk -F'[][]' '{ print $2 }')

# Check if Mute or Not
mute=$(amixer get Master | grep -o '\[on\]' >/dev/null && echo "Not Muted" || echo "Muted")

# Output the volume or mute status
if [[ $mute == "Muted" ]]; then
	echo "Muted"
else
	echo "$volume"
fi
