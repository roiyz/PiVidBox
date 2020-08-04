Raspberry Pi Video Box
=========================
<h2>Or how to repurpose old PIs and thumb drives as a super simple to use media box</h2>

Also check this related [article](https://magpi.raspberrypi.org/articles/pividbox) on the magpi magazine 

<h3>Intro</h3>
It's hard for me to count how many different online video services we have today. Hack, with cable and wireless services just bundling additional streaming services with their wireless accounts, I'm not sure I know how many streaming services our family is actually subscribed to. This is all great, and probably a great time to be alive,however, this also introduces another problem. I call it the Viewing Choice Paralysis

In some situations, the choice is easy when you just want to watch the newly, just released, episode of your favorite show, but in some other cases, instead of spending minutes trying to decide what to watch, all you want to do is just watch an episode or a movie that you may have watched before. For example, I'm a big fan of Seinfeld, where watching old episodes (that I've probably seen before multiple times) can still crack me up. The same goes for shows like "Who's line is it anyway", any monthy python episode or video and more. You get the point. So basically, to avoid the Viewing Choice Paralysis problem, I wanted to have something that chooses a random episode for me, with the requirement of me choosing a specific category to watch (e.g. comedy, kids stuff, specific series, etc).

<h3>Requirements</h3>
Considering the above, here is the list of requirements:

+ Reuse old hardware for playing videos 
+ Repurpose old (and perhaps small) no longer used thumb drives or memory cards 
+ 'Physical' Interface for choosing content type or category that my 3 year old can operate
+ And maybe most importantly, have a random mechanism that chooses the content for you to avoid the selection paralysis problem 
+ Adequate video play quality
+ Maintenance free

<h3>Hardware</h3>
Here is the list of items I used for this project:

+ Raspberry pi 2 (more on video play performance later)
+ 8GB and 32GB USB thumb drives (use any thumb drives you have)
+ 1GB and 8GB micro sd cards (use any SD cards you have)
+ SD card reader [amazon link](https://amzn.to/2KpWiOj)
+ USB A-Male to A-Female  extension cord [(similar on amazon)](https://amzn.to/2NUUf6P)
+ HDMI cable (not pictured)

![components image](https://raw.githubusercontent.com/roiyz/PiVidBox/master/images/components.jpg)

<h3>Software and setup</h3>
The general idea for this video box is a video player running in the background picks a andom video from the attached thumb drive. Once the selected video play is over, pick a new video, rinse and repeat. If the thumb drive is replaced, stop the current video and play a new video from the new thumb drive, simple, right? The only thing that you have to do is plug in your thumb drive with your favorite category, switch to the Pi's hdmi port and switch the PI on if it wasn't turned on already and just sit back and relax. 

For a video player, we'll use the already installed, and hardware optimized  [OMXplayer](https://www.raspberrypi.org/documentation/raspbian/applications/omxplayer.md). OMXplayer was very successful in running what ever video files I asked to run on our 4K Samsung TV. And this was running from a raspberry pi 2 model B, so this model or any newer model should probably give your really good video quality results. 

The rest of this guide also assumes you already have an updated raspberrypi with the latest [raspbian OS installed](https://www.raspberrypi.org/downloads/). To create the logic that constantly play videos from the flash drive, I wrote the following bash script as a [run.sh](https://github.com/roiyz/PiVidBox/blob/master/src/run.sh) file which should be placed under the __/home/pi__ directory:


```bash
#!/bin/bash
OIFS="$IFS"
IFS=$'\n'
echo "starting" > /tmp/log.txt
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
```

Download or copy the above file and save it under your /home/pi folder as run.sh. you should also modify its attributes to be an executable file by using the following command
```bash
chown +x /home/pi/run.sh
```
When executed, the above script tries to enumerate all video files on your thumb drive ending with .avi or .mp4, then shuffles them, and asks OMXplayer to play it one by one. When the cycle ends, the script sleeps for a bit, and then tries to start the play cycle again. 

Once you have the script copied, prepare a flash drive with a set of .avi or .mp4 videos in the root folder (it can contain other files or directories but make sure you have at least one video file at the root folder)

Feel free to test it by inserting the flash drive that contains a set of video files to the PI and just run the following command:
```bash
/home/pi/run.sh
```
If everything works well, after a few seconds, the videos will start playing in a full screen mode. If you want to exit the cycle, just pull out the flash drive and wait for the cycle to end. You may also hit CTRL-C to stop the script. 

That's great, but we want to have this script run automatically on boot rather than starting it each time. To do that, we'll add a file to the /etc/xdg/lxsession/LXDE-pi/autostart file by running the following command: 
```bash
 sudo echo "/home/pi/run.sh" | sudo tee /etc/xdg/lxsession/LXDE-pi/autostart
```

That's it! to test it, hook up the raspberry pi to your tv, hook up the extensions cable (optional), make sure you have a flash drive inserted to one of the USB ports or the extension cable, reboot the pi (as described below) and just sit back relax and watch your shows. 

```bash 
sudo reboot
```

Switch the USB drives if you want to view other videos, the raspberry pi will just switch videos as soon as it detects the USB drive was switched. You may just leave it turned on or turn if off when you're done.






<h3>Bonus</h3>
If you have access to a 3d printer, you can also print the following USB drives and sd 
cards 
[stand]("https://www.thingiverse.com/thing:3983948") with a hook for the USB extension cable. 
You can also place some stickers to easily identify the contents of each usb drive just like I did.

![USB stand](https://raw.githubusercontent.com/roiyz/PiVidBox/master/images/in_action.jpg)


<h3>Troubleshooting</h3>
If you follow the instructions listed above but still no video is shown perform the following steps:

+ Make sure you have at least one or more .avi or .mp4 videos in your flash drive. 
+ the script writes logs to the /tmp/out.txt file. use the following command to see if the script actually is executed and what videos are being played
+ If you raise your hands in defeat and nothing seems to work, open an issue here and I'll try to do my best to help ;)


<h3>Caveats and things to improve in the future</h3>
Obviously, there are a few things that can be improved, some of them are:

+ Smoother transition between videos. Currently, the desktop is showing when one video ends and before the next video starts. It would be nice to have a fadeout and fade in kind of a transition between videos
+ I haven't tested this on newer pi versions (e.g. 3 and 4 versions) so hope this works on newer versions as well
+ When switching USBs, OMXplayer takes a minute or two to recognize that the previous USB no longer exist and stop playing whatever it has in the cache. I've played a bit with the OMXplayer parameters but couldn't force it to run with a short buffer. Maybe there's a hidden or undocumented OMXplater parameter that I'm not aware of that can solve this problem.

<h3>Closing words</h3> 
I hope this tutorial helps you use your old hardware to setup your fully automated pi video box. I have it running at my home, used by all family members, and the list of video catalog just grows over time whenever we find a new thumb drive we longer use. 
If you are using it successfully or have suggestions for improvements, feel free to leave a comment. 
