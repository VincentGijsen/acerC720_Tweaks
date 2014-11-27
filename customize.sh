#!/bin/bash

#
#	Author: Vincent Gijsen
#	Laptop: Chromebook Acer C720, 2GB RAM, 16GB ssd
#	Bios: Corebios vanilla
#

#multimedia mapping
echo writing Mapping for multimedia keys
XFMapping=~/.Xmodmap
cat << EOM >$XFMapping
keycode 76 = XF86AudioRaiseVolume
keycode 75 = XF86AudioLowerVolume
keycode 74 = XF86AudioMute 
keycode 73 = XF86MonBrightnessUp NoSymbol XF86MonBrightnessUp
keycode 72 = XF86MonBrightnessDown NoSymbol XF86MonBrightnessDown
!keycode 71 NOT USED
!keycode 70 = NOT USED
keycode 69 = XF86AudioPlay XF86AudioPause XF86AudioPlay XF86AudioPause
keycode 68 = XF86AudioNext
keycode 67 = XF86AudioPrev
EOM


echo Adding autostart to xinitrc for mapping keys 
echo 
echo
echo "#autostart mapping for keys" >> ~/.xinitrc
echo "xmodmap .Xmodmap" >> ~/.xinitrc

#install xbind for spotify controll

sudo apt-get install xbindkeys

XBINDFILE=~/.xbindsrc
cat << EOM >$XBINDFILE
"dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause"
XF86AudioPlay
"dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop"
XF86AudioStop
"dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next"
XF86AudioNext
"dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous"
XF86AudioPrev
EOM

#add xbind to autostart

echo "xbindkeys" >> ~/.xinitrc


#trackpad tuning

echo tuning trackpad settings
echo 
echo

cat << EOM > ~/.XinputTrackpad
#!/bin/bash 
DEVID=12
xinput --set-prop \$DEVID "Synaptics Finger" 8 16 0
xinput --set-prop \$DEVID "Synaptics Soft Button Areas" 0 0 0 0 0 0 0
EOM
echo "\nAutostart tuning of touchpad\n$XINPUTTUNING\n" 
echo "sh ~/.XinputTrackpad" >> .xinitrc

#Wifi tuning
sudo bash -c 'echo options ath9k btcoex_enable=1 ps_enable=1 bt_ant_diversity=1 >/etc/modprobe.d/ath9k.conf'

sudo bash -c 'echo "echo TPAD > /proc/acpi/wakeup" >> /etc/rc.local'

sudo bash -c 'cat << EOM > /etc/rc.local
echo EHCI > /proc/acpi/wakeup
echo HDEF > /proc/acpi/wakeup
echo XHCI > /proc/acpi/wakeup
echo LID0 > /proc/acpi/wakeup
echo TPAD > /proc/acpi/wakeup
echo TSCR > /proc/acpi/wakeup
echo 300 > /sys/class/backlight/intel_backlight/brightness

exit 0
EOM
'

#sleep stuff
sudo bash -c 'cat << EOM >/etc/pm/sleep.d/05_sound
#####################
#!/bin/sh
# File: "/etc/pm/sleep.d/05_sound"
case "${1}" in
hibernate|suspend)
# Unbind ehci for preventing error
echo -n "0000:00:1d.0" | tee /sys/bus/pci/drivers/ehci-pci/unbind
# Unbind snd_hda_intel for sound
echo -n "0000:00:1b.0" | tee /sys/bus/pci/drivers/snd_hda_intel/unbind
echo -n "0000:00:03.0" | tee /sys/bus/pci/drivers/snd_hda_intel/unbind
sleep 1
;;
resume|thaw)
# Bind ehci for preventing error
echo -n "0000:00:1d.0" | tee /sys/bus/pci/drivers/ehci-pci/bind
# Bind snd_hda_intel for sound
echo -n "0000:00:1b.0" | tee /sys/bus/pci/drivers/snd_hda_intel/bind
echo -n "0000:00:03.0" | tee /sys/bus/pci/drivers/snd_hda_intel/bind
sleep 1
;;
esac
#################
EOM
'
sudo chmod +x /etc/pm/sleep.d/05_sound


