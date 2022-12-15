#!/bin/bash -e

# sudo sh enable-hifiberry.sh
BWhite='\033[1;37m'; RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m' # color
if
[ $(id -u) -ne 0 ]; then echo "Please run as root"; exit 1; fi
echo

#### HiFiberry DAC ####
echo -n ${BWhite}"Use HiFiberry DAC (PCM5102) ? yes / no "${NC}
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
	if grep -Fxq 'dtoverlay=hifiberry-dac' '/boot/config.txt' ;then
		echo ${GREEN}"Enabled HiFiberry DAC"${NC}
	elif grep -Fxq '#dtoverlay=hifiberry-dac' '/boot/config.txt' ;then
		sed -i 's/#dtoverlay=hifiberry-dac/dtoverlay=hifiberry-dac/' /boot/config.txt
		sed -i 's/dtparam=audio=on/#dtparam=audio=on/' /boot/config.txt
		echo ${GREEN}"Enabled HiFiberry DAC"${NC}
	else
		sed -i 's/dtparam=audio=on/#dtparam=audio=on/' /boot/config.txt
		cat <<'EOF' >> /boot/config.txt

dtoverlay=hifiberry-dac
EOF
		echo ${GREEN}"Enabled HiFiberry DAC ? yes / no "${NC}
	fi
	cat <<'EOF' > /etc/asound.conf
defaults.pcm.card 0
defaults.ctl.card 0

pcm.hifiberry {
  type hw
  card 0
  device 0
}
pcm.dmixer {
  type dmix
  ipc_key 1024
  ipc_perm 0666
  slave.pcm "hifiberry"
  slave {
    period_time 0
    period_size 1024
    buffer_size 8192
    rate 44100
    format S32_LE
  }
  bindings {
    0 0
    1 1
  }
}
ctl.dmixer {
  type hw
  card 0
}
pcm.softvol {
  type softvol
  slave.pcm "dmixer"
  control {
    name "Softvol"
    card 0
  }
  min_dB -90.2
  max_dB 0.0
}
pcm.!default {
  type plug
  slave.pcm "softvol"
}
EOF
	echo ${GREEN}"ADD /etc/asound.conf"${NC}
else
	if grep -Fxq 'dtoverlay=hifiberry-dac' '/boot/config.txt' ;then
		rm /etc/asound.conf
		sed -i 's/dtoverlay=hifiberry-dac/#dtoverlay=hifiberry-dac/' /boot/config.txt
		sed -i 's/#dtparam=audio=on/dtparam=audio=on/' /boot/config.txt
		echo ${GREEN}"Disabled HiFiberry DAC (PCM5102)"${NC}

	fi
fi
