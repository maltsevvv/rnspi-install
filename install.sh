#!/bin/bash

BWhite='\033[1;37m'; BBlue='\033[1;34m'; RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m' # color
if
[ $(id -u) -ne 0 ]; then echo "Please run as root"; exit 1; fi

if grep -Fxq 'VERSION="11 (bullseye)"' '/etc/os-release'; then echo ${GREEN}"You using Raspbian Bullseye"${NC}
elif grep -Fxq 'VERSION="10 (buster)"' '/etc/os-release'; then echo ${GREEN}"You using Raspbian Buster"${NC}
fi 
echo

echo ${BWhite}"Сhecking the internet connection"${NC}
echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1
[ $? -eq 0 ]
if [ $? -eq 0 ]; then echo ${GREEN}"OK"${NC}; else echo ${RED}"NOT internet connection"${NC}; exit 0; fi
echo

echo ${BWhite}"Check file on SD card in /boot/ SKIN.RNSD or SKIN.RNSE"${NC}
if [ -e /boot/skin.rnsd*.zip ]; then
	echo ${GREEN}"FOUND SKIN.RNS-D"${NC}
elif [ -e /boot/skin.rnse*.zip ]; then
	echo ${GREEN}"FOUND SKIN.RNS-E"${NC}
else 
	echo ${RED}"SKIN not found"${NC}
	exit 0
fi

echo ${BWhite}"Update system"${NC}
apt update -y
echo
#
#
##############################################
#              INSTALL KODI                  #
##############################################
echo ${BWhite}"Install kodi"${NC}
apt install -y kodi
cat <<'EOF' > /etc/systemd/system/kodi.service
[Unit]
Description=Kodi Media Center
[Service]
User=pi
Group=pi
Type=simple
ExecStart=/usr/bin/kodi-standalone
Restart=always
RestartSec=15
[Install]
WantedBy=multi-user.target
EOF

# Disable versioncheck
sed -i '/service.xbmc.versioncheck/d' /usr/share/kodi/system/addon-manifest.xml
echo ${GREEN}"Disable service.xbmc.versioncheck"${NC}
#
systemctl enable kodi.service
systemctl start kodi.service
echo
#
#
##############################################
#               INSTALL CanBus               #
##############################################
echo ${BWhite}"Install can-utils"${NC}
apt install -y can-utils
echo
#
echo ${BWhite}"Install python-pip"${NC}
if grep -Fxq 'VERSION="11 (bullseye)"' '/etc/os-release'; then
	apt install -y python3-pip
elif grep -Fxq 'VERSION="10 (buster)"' '/etc/os-release'; then
	apt install -y python-pip
fi
#
echo ${BWhite}"Install python-can"${NC}
pip install python-can
echo
#
cat <<'EOF' >> /etc/network/interfaces
auto can0
  iface can0 inet manual
  pre-up /sbin/ip link set can0 type can bitrate 100000
  up /sbin/ifconfig can0 up
  down /sbin/ifconfig can0 down
EOF

echo ${BWhite}"Enable MCP2515 CanBus /boot/config.txt"${NC}
cat <<'EOF' >> /boot/config.txt

# Enable MCP2515 CanBus
dtparam=spi=on
dtoverlay=mcp2515-can0,oscillator=8000000,interrupt=25
dtoverlay=spi-bcm2835-overlay
EOF
echo
#
#
##############################################
#               INSTALL SAMBA                #
##############################################
echo ${BWhite}"Install samba"${NC}
echo "samba-common samba-common/workgroup string  WORKGROUP" | sudo debconf-set-selections
echo "samba-common samba-common/dhcp boolean true" | sudo debconf-set-selections
echo "samba-common samba-common/do_debconf boolean true" | sudo debconf-set-selections
apt install -y samba
#config samba
cat <<'EOF' >> /etc/samba/smb.conf
[rns]
path = /home/pi/
create mask = 0775
directory mask = 0775
writeable = yes
browseable = yes
public = yes
force user = root
guest ok = yes
EOF
service smbd restart
echo ${GREEN}"OK"${NC}
echo
#
echo ${BWhite}"Сreate media folder"${NC}
mkdir /home/pi/movies /home/pi/music /home/pi/mults /home/pi/clips
chmod -R 0777 /home/pi/movies /home/pi/music /home/pi/mults /home/pi/clips
echo
#
#
##############################################
#             INSTALL SKIN RNS*              #
##############################################
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
##############################################
#             INSTALL SKIN RNSD              #
##############################################
if [ -e /boot/skin.rnsd*.zip ] ; then
	# OS BULLSEYE #
	if grep -Fxq 'VERSION="11 (bullseye)"' '/etc/os-release'; then
		unzip /boot/skin.rnsd*bullseye.zip -d /home/pi/.kodi/addons/ > /dev/null 2>&1
		cp /home/pi/.kodi/addons/skin.rnsd/tvtuner.pyc /usr/local/bin/
		cat <<'EOF' > /etc/systemd/system/tvtuner.service
[Unit]
Description=Emulation tv-tuner 4DO919146B
[Service]
Type=simple
ExecStart=/usr/bin/python /usr/local/bin/tvtuner.pyc
Restart=always
[Install]
WantedBy=multi-user.target
EOF
	# OS BUSTER #
	elif grep -Fxq 'VERSION="10 (buster)"' '/etc/os-release'; then
		unzip /boot/skin.rnsd*buster.zip -d /home/pi/.kodi/addons/ > /dev/null 2>&1
		cp /home/pi/.kodi/addons/skin.rnsd/tvtuner.pyo /usr/local/bin/
		cat <<'EOF' > /etc/systemd/system/tvtuner.service
[Unit]
Description=Emulation tv-tuner 4DO919146B
[Service]
Type=simple
ExecStart=/usr/bin/python /usr/local/bin/tvtuner.pyo
Restart=always
[Install]
WantedBy=multi-user.target
EOF
	fi
	systemctl enable tvtuner.service
	sed -i -e '$i \  <addon optional="true">skin.rnsd</addon>' /usr/share/kodi/system/addon-manifest.xml
	sed -i 's/lookandfeel.skin" default="true">skin.estuary/lookandfeel.skin">skin.rnsd/' /home/pi/.kodi/userdata/guisettings.xml
	echo ${GREEN}"SKIN.RNSD INSTALLED BY DEFAULT"${NC}

##############################################
#             INSTALL SKIN RNSE              #
##############################################
elif [ -e /boot/skin.rnse*.zip ] ; then
	# OS BULLSEYE #
	if grep -Fxq 'VERSION="11 (bullseye)"' '/etc/os-release'; then
	unzip /boot/skin.rnse*bullseye.zip -d /home/pi/.kodi/addons/ > /dev/null 2>&1
	# OS BUSTER #
	elif grep -Fxq 'VERSION="10 (buster)"' '/etc/os-release'; then
		unzip /boot/skin.rnse*buster.zip -d /home/pi/.kodi/addons/ > /dev/null 2>&1
	fi
	sed -i -e '$i \  <addon optional="true">skin.rnse</addon>' /usr/share/kodi/system/addon-manifest.xml
	sed -i 's/lookandfeel.skin" default="true">skin.estuary/lookandfeel.skin">skin.rnse/' /home/pi/.kodi/userdata/guisettings.xml
	echo ${GREEN}"SKIN.RNSE INSTALLED BY DEFAULT"${NC}

fi
#
#
##############################################
#       HDMI to VGA adapter for RNS          #
##############################################
echo -n ${BWhite}"Use HDMI to VGA adapter ? yes / no "${NC}
read answer
if [ "$answer" != "${answer#[Y|y]}" ]; then
	sed -i 's/#hdmi_force_hotplug=1/hdmi_force_hotplug=1/' /boot/config.txt
	sed -i 's/#disable_overscan=1/disable_overscan=1/' /boot/config.txt
	sed -i 's/dtoverlay=vc4-kms-v3d/dtoverlay=vc4-fkms-v3d/' /boot/config.txt
	cat <<'EOF' >> /boot/config.txt

# HDMI to VGA adapter for RNS
hdmi_ignore_edid=0xa5000080
hdmi_group=2
hdmi_mode=87
hdmi_timings 800 0 51 44 121 460 0 10 9 14 0 0 0 32 1 16000000 3
framebuffer_width=400
framebuffer_height=230
EOF
fi
#
#
##############################################
#      INSTALL HiFiberry DAC PCM5102         #
##############################################
echo -n ${BWhite}"Use HiFiberry DAC (PCM5102) ? yes / no "${NC}
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
	sed -i 's/dtparam=audio=on/#dtparam=audio=on/' /boot/config.txt
	cat <<'EOF' >> /boot/config.txt

dtoverlay=hifiberry-dac
EOF
	echo ${GREEN}"Enabled HiFiberry DAC ? yes / no "${NC}
fi
#
#
##############################################
#                SETTINGS KODI               #
##############################################

# Add sources /home/pi/movies/ & /home/pi/music/

cat <<'EOF' >> /home/pi/.kodi/userdata/sources.xml
<sources>
   <programs>
       <default pathversion="1"></default>
   </programs>
   <video>
       <default pathversion="1"></default>
       <source>
           <name>movies</name>
           <path pathversion="1">/home/pi/movies/</path>
           <allowsharing>true</allowsharing>
       </source>
   </video>
   <music>
       <default pathversion="1"></default>
       <source>
           <name>music</name>
           <path pathversion="1">/home/pi/music/</path>
           <allowsharing>true</allowsharing>
       </source>
   </music>
   <pictures>
       <default pathversion="1"></default>
   </pictures>
   <files>
       <default pathversion="1"></default>
   </files>
   <games>
       <default pathversion="1"></default>
   </games>
</sources>
EOF

sudo chown pi:pi /home/pi/.kodi/userdata/sources.xml

echo ${GREEN}"Add sources /home/pi/"${NC}

# Disable Screensaver
sed -i 's/id="screensaver.mode" default="true">screensaver.xbmc.builtin.dim/id="screensaver.mode">/' /home/pi/.kodi/userdata/guisettings.xml
echo ${GREEN}"Disable Screensaver"${NC}

# Enable auto play next video
sed -i 's/id="videoplayer.autoplaynextitem" default="true">/id="videoplayer.autoplaynextitem">0,1,2,3,4/' /home/pi/.kodi/userdata/guisettings.xml
echo ${GREEN}"Enable auto play next video"${NC}

# Amplifi volume up to 30.0dB
sed -i 's/volumeamplification>0.000000/volumeamplification>30.000000/' /home/pi/.kodi/userdata/guisettings.xml
echo ${GREEN}"Amplifi volume up to 30.0dB"${NC}

# Enable web-server
sed -i 's/id="services.webserverauthentication" default="true">true/id="services.webserverauthentication">false/' /home/pi/.kodi/userdata/guisettings.xml
sed -i 's/id="services.webserver" default="true">false/id="services.webserver">true/' /home/pi/.kodi/userdata/guisettings.xml
echo ${GREEN}"Enable web-server"${NC}
echo $(hostname -I):8080
#
#
##############################################
#         INSTALL BLUETOOTHE RECIEVER        #
##############################################
echo -n ${BWhite}"INSTALL BLUETOOTHE RECIEVER ? yes / no "${NC}
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
	hostnamectl set-hostname --pretty "rns"
	apt install -y --no-install-recommends pulseaudio
	usermod -a -G pulse-access root
	usermod -a -G bluetooth pulse
	mv /etc/pulse/client.conf /etc/pulse/client.conf.orig
	cat <<'EOF' >> /etc/pulse/client.conf
default-server = /run/pulse/native
autospawn = no
EOF
	sed -i '/^load-module module-native-protocol-unix$/s/$/ auth-cookie-enabled=0 auth-anonymous=1/' /etc/pulse/system.pa
# PulseAudio system daemon
	cat <<'EOF' > /etc/systemd/system/pulseaudio.service
[Unit]
Description=Sound Service
[Install]
WantedBy=multi-user.target
[Service]
Type=notify
PrivateTmp=true
ExecStart=/usr/bin/pulseaudio --daemonize=no --system --disallow-exit --disable-shm --exit-idle-time=-1 --log-target=journal --realtime --no-cpu-limit
Restart=on-failure
EOF
	systemctl enable --now pulseaudio.service
	systemctl --global mask pulseaudio.socket
	apt install -y --no-install-recommends bluez-tools pulseaudio-module-bluetooth
	# Bluetooth settings
	cat <<'EOF' > /etc/bluetooth/main.conf
[General]
Class = 0x200414
DiscoverableTimeout = 0

[Policy]
AutoEnable=true
EOF
	# Make Bluetooth discoverable after initialisation
	mkdir -p /etc/systemd/system/bthelper@.service.d
	cat <<'EOF' > /etc/systemd/system/bthelper@.service.d/override.conf
[Service]
Type=oneshot
EOF

	cat <<'EOF' > /etc/systemd/system/bt-agent@.service
[Unit]
Description=Bluetooth Agent
Requires=bluetooth.service
After=bluetooth.service

[Service]
ExecStartPre=/usr/bin/bluetoothctl discoverable on
ExecStartPre=/bin/hciconfig %I piscan
ExecStartPre=/bin/hciconfig %I sspmode 1
ExecStart=/usr/bin/bt-agent --capability=NoInputNoOutput
RestartSec=5
Restart=always
KillSignal=SIGUSR1

[Install]
WantedBy=multi-user.target
EOF
	systemctl daemon-reload
	systemctl enable bt-agent@hci0.service
	usermod -a -G bluetooth pulse

	# PulseAudio settings
	echo "load-module module-bluetooth-policy" >> /etc/pulse/system.pa
	echo "load-module module-bluetooth-discover" >> /etc/pulse/system.pa

	# Bluetooth udev script
	cat <<'EOF' > /usr/local/bin/bluetooth-udev
#!/bin/bash
if [[ ! $NAME =~ ^\"([0-9A-F]{2}[:-]){5}([0-9A-F]{2})\"$ ]]; then exit 0; fi

action=$(expr "$ACTION" : "\([a-zA-Z]\+\).*")

if [ "$action" = "add" ]; then
    bluetoothctl discoverable off
    # disconnect wifi to prevent dropouts
    #ifconfig wlan0 down &
fi

if [ "$action" = "remove" ]; then
    # reenable wifi
    #ifconfig wlan0 up &
    bluetoothctl discoverable on
fi
EOF
	chmod 755 /usr/local/bin/bluetooth-udev

	cat <<'EOF' > /etc/udev/rules.d/99-bluetooth-udev.rules
SUBSYSTEM=="input", GROUP="input", MODE="0660"
KERNEL=="input[0-9]*", RUN+="/usr/local/bin/bluetooth-udev"
EOF

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
	echo ${GREEN}"Add config /etc/asound.conf"${NC}

#               BluetoothManager          #
	unzip /home/pi/.kodi/addons/skin.rns*/resources/Bluetooth*.zip -d /home/pi/.kodi/addons/ > /dev/null 2>&1
	sed -i -e '$i \  <addon optional="true">script.bluetooth.man</addon>' /usr/share/kodi/system/addon-manifest.xml
else
	cat <<'EOF' >> /boot/config.txt
dtoverlay=disable-bt
EOF
	echo ${GREEN}"Bluetooth Disable"${NC}
fi
#
#
##############################################
#               INSTALL USBMOUNT             #
##############################################
if grep -Fxq 'VERSION="10 (buster)"' '/etc/os-release'; then
	echo ${BWhite}"install usbmount"${NC}
	apt install -y usbmount
	mkdir /home/pi/tmpu && cd /home/pi/tmpu
	wget https://github.com/nicokaiser/usbmount/releases/download/0.0.24/usbmount_0.0.24_all.deb
	dpkg -i usbmount_0.0.24_all.deb
	cd /home/pi && rm -Rf /home/pi/tmpu
	# ADD CIRILIC  UTF-8
	sed -i 's/FS_MOUNTOPTIONS=""/FS_MOUNTOPTIONS="-fstype=vfat,iocharset=utf8,gid=1000,dmask=0007,fmask=0007"/' /etc/usbmount/usbmount.conf
	sed -i 's/FILESYSTEMS="vfat ext2 ext3 ext4 hfsplus"/FILESYSTEMS="vfat ext2 ext3 ext4 hfsplus ntfs fuseblk"/' /etc/usbmount/usbmount.conf
fi
echo
#
#
##############################################
#                 REBOOT SYSTEM              #
##############################################
echo -n ${BWhite}"Reboot System Now ? yes / no "${NC}
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
	reboot
fi
