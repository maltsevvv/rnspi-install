#!/bin/bash

# sudo sh video-output.sh
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

# HDMI to VGA adapter for RNS
echo -n ${BWhite}"Use HDMI to VGA adapter ? yes / no "${NC}
read answer
if [ "$answer" != "${answer#[Y|y]}" ]; then
	if grep -Fxq 'sdtv_mode=2' '/boot/config.txt'; then
		sed -i 's/sdtv_mode=2/#sdtv_mode=2/' /boot/config.txt
	fi
	if grep -Fxq '# HDMI to VGA adapter for RNS' '/boot/config.txt'; then
		echo
	else
		cat <<'EOF' >> /boot/config.txt

# HDMI to VGA adapter for RNS
hdmi_group=1
hdmi_mode=6
EOF
		sed -i 's/#hdmi_force_hotplug=1/hdmi_force_hotplug=1/' /boot/config.txt
	fi
else
	if grep -Fxq '#sdtv_mode=2' '/boot/config.txt'; then
		sed -i 's/#sdtv_mode=2/sdtv_mode=2/' /boot/config.txt
	fi
	if grep -Fxq '# HDMI to VGA adapter for RNS' '/boot/config.txt'; then
		sed -i '/# HDMI to VGA adapter for RNS/d' /boot/config.txt
		sed -i '/hdmi_group=1/d' /boot/config.txt
		sed -i '/hdmi_mode=6/d' /boot/config.txt
		sed -i 's/hdmi_force_hotplug=1/#hdmi_force_hotplug=1/' /boot/config.txt

	fi	
fi
