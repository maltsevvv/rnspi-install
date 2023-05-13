#!/bin/bash

BWhite='\033[1;37m'; BBlue='\033[1;34m'; RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m' # color
if
[ $(id -u) -ne 0 ]; then echo "Please run as root"; exit 1; fi

if grep -Fxq 'VERSION="11 (bullseye)"' '/etc/os-release'; then echo ${GREEN}"You using Raspbian Bullseye"${NC}
elif grep -Fxq 'VERSION="10 (buster)"' '/etc/os-release'; then echo ${GREEN}"You using Raspbian Buster"${NC}
fi 
echo

echo ${BWhite}"START UPDATE"${NC}
##############################################
#                 STOP KODI                  #
##############################################
if (systemctl -q is-active kodi.service); then
	echo ${BWhite}"stop kodi (10sec.)"${NC}
	systemctl stop kodi
	sleep 10
elif (systemctl -q is-active kodi.service); then
	echo ${BWhite}"stop kodi (+10sec.)"${NC}
	systemctl stop kodi
	sleep 10
exit 1
fi
echo


##############################################
#             UPDATE SKIN RNSD              #
##############################################
if [ -e /home/pi/skin.rns*.zip ] ; then
	if [ -e /home/pi/.kodi/addons/skin.rnsd ] ; then
		rm -r /home/pi/.kodi/addons/skin.rnsd/
		# OS BULLSEYE #
		if grep -Fxq 'VERSION="11 (bullseye)"' '/etc/os-release'; then
			unzip /home/pi/skin.rnsd*bullseye.zip -d /home/pi/.kodi/addons/ > /dev/null 2>&1
		# OS BUSTER #
		elif grep -Fxq 'VERSION="10 (buster)"' '/etc/os-release'; then
			unzip /home/pi/skin.rnsd*buster.zip -d /home/pi/.kodi/addons/ > /dev/null 2>&1
		fi
	fi
	echo ${GREEN}"SKIN.RNSD UPDATE"${NC}

##############################################
#             UPDATE SKIN RNSE              #
##############################################
	elif [ -e /home/pi/.kodi/addons/skin.rnse ] ; then
		rm -r /home/pi/.kodi/addons/skin.rnse/
		# OS BULLSEYE #
		if grep -Fxq 'VERSION="11 (bullseye)"' '/etc/os-release'; then
			unzip /home/pi/skin.rnse*bullseye.zip -d /home/pi/.kodi/addons/ > /dev/null 2>&1
		# OS BUSTER #
		elif grep -Fxq 'VERSION="10 (buster)"' '/etc/os-release'; then
			unzip /boot/skin.rnse*buster.zip -d /home/pi/.kodi/addons/ > /dev/null 2>&1
		fi
		echo ${GREEN}"SKIN.RNSE UPDATE"${NC}
	fi
	echo ${GREEN}"UPDATE SKIN FINISH"${NC}
fi
#
systemctl start kodi
