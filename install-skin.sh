#!/bin/bash

# sudo sh install-skin.sh
BWhite='\033[1;37m'; RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m' # color
if
[ $(id -u) -ne 0 ]; then echo "Please run as root"; exit 1; fi

if (systemctl -q is-active kodi.service); then
	echo ${BWhite}"stop kodi (10sec.)"${NC}
	systemctl stop kodi.service
	sleep 10
elif (systemctl -q is-active kodi.service); then
	echo ${BWhite}"stop kodi (+10sec.)"${NC}
	systemctl stop kodi.service
	sleep 10
exit 1
fi
echo

echo ${BWhite}"Check file on SD card in /boot/ SKIN.RNSD or SKIN.RNSE"${NC}
if [ -e /boot/skin.rnsd-main.zip ]; then
	echo ${GREEN}"FOUND SKIN.RNS-D"${NC}
elif [ -e /boot/skin.rnse-main.zip ]; then
	echo ${GREEN}"FOUND SKIN.RNS-E"${NC}
else 
	echo ${RED}"SKIN not found"${NC}
	echo ${RED}"Name should be skin.rnsd-main.zip"${NC}
	echo ${RED}"Name should be skin.rnse-main.zip"${NC}
	exit 0
fi
echo
####

echo ${BWhite}"Сreate media folder"${NC}
mkdir /home/pi/movies /home/pi/music /home/pi/mults
chmod -R 0777 /home/pi/movies /home/pi/music /home/pi/mults
echo ${GREEN}"OK"${NC}
echo
####

# install skin.rnsd
if [ -e /boot/skin.rnsd-main.zip ] ; then
	echo ${BWhite}"Install SKIN.RNSD"${NC}
	unzip /boot/skin.rnsd-main.zip -d /tmp/ > /dev/null 2>&1
	mv /tmp/skin.rnsd-main /tmp/skin.rnsd
	rm -r /home/pi/.kodi/addons/skin.rnsd
	cp /tmp/skin.rnsd -r /home/pi/.kodi/addons/ > /dev/null 2>&1
	sed -i -e '$i \  <addon optional="true">skin.rnsd</addon>' /usr/share/kodi/system/addon-manifest.xml
	sed -i 's/lookandfeel.skin" default="true">skin.estuary/lookandfeel.skin">skin.rnsd/' /home/pi/.kodi/userdata/guisettings.xml
	echo ${GREEN}"SKIN.RNSD INSTALLED BY DEFAULT"${NC}
	echo
# install tvtuner for rnsd
	echo -n ${BWhite}"EMULATE TV-TUNER 4DO919146B FOR RNSD ? yes / no "${NC}
	read answer
	if [ "$answer" != "${answer#[Yy]}" ] ;then
		cat <<'EOF' > /etc/systemd/system/tvtuner.service
[Unit]
Description=Emulation tv-tuner 4DO919146B
[Service]
Type=simple
ExecStart=/usr/bin/python /home/pi/.kodi/addons/skin.rnsd/tvtuner.pyo
Restart=always
[Install]
WantedBy=multi-user.target
EOF
		systemctl enable tvtuner.service
		echo ${GREEN}"TV-TUNER FOR RNSD INSTALLED"${NC}
	else
		systemctl stop tvtuner.service
		systemctl disable tvtuner.service
		rm /etc/systemd/system/tvtuner.service
	fi
# install skin.rnse
elif [ -e /boot/skin.rnse-main.zip ] ; then
	echo ${BWhite}"Install or SKIN.RNSE"${NC}
	unzip /boot/skin.rnse-main.zip -d /tmp/ > /dev/null 2>&1
	mv /tmp/skin.rnse-main /tmp/skin.rnse
	rm -r /home/pi/.kodi/addons/skin.rnse
	cp /tmp/skin.rnse -r /home/pi/.kodi/addons/ > /dev/null 2>&1
	sed -i -e '$i \  <addon optional="true">skin.rnse</addon>' /usr/share/kodi/system/addon-manifest.xml
	sed -i 's/lookandfeel.skin" default="true">skin.estuary/lookandfeel.skin">skin.rnse/' /home/pi/.kodi/userdata/guisettings.xml
	echo ${GREEN}"SKIN.RNSE INSTALLED BY DEFAULT"${NC}
	echo
# install tvtuner for rnsd
	echo -n ${BWhite}"EMULATE TV-TUNER FOR RNSE ? yes / no "${NC}
	read answer
	if [ "$answer" != "${answer#[Yy]}" ] ;then
		cat <<'EOF' > /etc/systemd/system/tvtuner.service
[Unit]
Description=Emulation tv-tuner 4DO919146B
[Service]
Type=simple
ExecStart=/usr/bin/python /home/pi/.kodi/addons/skin.rnse/tvtuner.pyo
Restart=always
[Install]
WantedBy=multi-user.target
EOF
		systemctl enable tvtuner.service
		echo ${GREEN}"TV-TUNER FOR RNSE INSTALLED"${NC}
	else
		systemctl stop tvtuner.service
		systemctl disable tvtuner.service
		rm /etc/systemd/system/tvtuner.service
	fi
fi
