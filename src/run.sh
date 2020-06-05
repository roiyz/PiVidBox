#!/bin/bash
OIFS="$IFS"
IFS=$'\n'
echo "starting" > /tmp/out.txt
sleep 10
while true
do
	for file in `find /media/pi -type f \( -iname \*.avi -o -iname \*.mp4 \) | shuf`
                do
			echo "$file"
                        echo "$file" >>/tmp/out.txt
			/usr/bin/omxplayer --adev hdmi --aspect-mode stretch --threshold 5 $file
                done
	echo "Completed cycle" >>/tmp/out.txt
	sleep 10
done

