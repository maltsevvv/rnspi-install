#!/bin/bash

BWhite='\033[1;37m'; BBlue='\033[1;34m'; RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m' # color
IP=$(hostname -I)

if
[ $(id -u) -ne 0 ]; then
	echo "Please run as root"
	exit 1
fi

echo ${BWhite}"Сhecking the internet connection"${NC}
echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1
[ $? -eq 0 ]
if [ $? -eq 0 ]; thenecho ${GREEN}"Internet connected"${NC}; else echo ${RED}"NOT internet connection"${NC}; exit 0; fi
echo

echo ${BWhite}"Сhecking Version Raspbian and Version skin.rns*"${NC}
if grep -Fxq 'VERSION="10 (buster)"' '/etc/os-release'; then
	echo ${GREEN}"Raspbian Buster"${NC}
	if [ -e /boot/skin.rns*buster.zip ] ; then
		echo ${GREEN}"Skin for Buster"${NC}
	else
		echo ${RED}"NOT found skin for Buster on SD card in /boot/"${NC}
		exit 0
	fi
elif grep -Fxq 'VERSION="11 (bullseye)"' '/etc/os-release'; then 
	echo ${GREEN}"Raspbian Bullseye"${NC}
	if [ -e /boot/skin.rns*bullseye.zip ] ; then
		echo ${GREEN}"Skin for Bullseye"${NC}
	else
		echo ${RED}"NOT found skin for Bullseye on SD card in /boot/"${NC}
		exit 0
	fi
fi
echo

echo ${BWhite}"Update system"${NC}
apt update -y > /dev/null 2>&1
if [ $? -eq 0 ]
then
	echo ${GREEN}"Successfully"${NC}
else
	echo ${RED}"NOT system update"${NC}
	exit 0
fi
echo
#
#
##############################################
#              INSTALL KODI                  #
##############################################
echo ${BWhite}"Installing KODI"${NC}
apt install -y kodi > /dev/null 2>&1
if [ $? -eq 0 ]; then
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
	echo ${GREEN}"Successfully"${NC}
	systemctl enable kodi.service
	systemctl start kodi.service
else
	echo ${RED}"NOT installed"${NC}
	exit 0
fi
echo
#
#
##############################################
#               INSTALL CanBus               #
##############################################
echo ${BWhite}"Installing can-utils"${NC}
apt install -y can-utils  > /dev/null 2>&1
if [ $? -eq 0 ]; then
	if grep -Fxq 'auto can0' '/etc/network/interfaces'; then
		echo
	else
		cat <<'EOF' >> /etc/network/interfaces
auto can0
  iface can0 inet manual
  pre-up /sbin/ip link set can0 type can bitrate 100000
  up /sbin/ifconfig can0 up
  down /sbin/ifconfig can0 down
EOF
	fi
	echo ${GREEN}"Successfully"${NC}
else
	echo ${RED}"NOT installed"${NC}
	exit 0
fi
echo
#
echo ${BWhite}"Installing python-pip"${NC}
if grep -Fxq 'VERSION="11 (bullseye)"' '/etc/os-release'; then
	apt install -y python3-pip  > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo ${GREEN}"Successfully"${NC}
	else
		echo ${RED}"NOT installed"${NC}
		exit 0
	fi
elif grep -Fxq 'VERSION="10 (buster)"' '/etc/os-release'; then
	apt install -y python-pip  > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo ${GREEN}"Successfully"${NC}
	else
		echo ${RED}"NOT installed"${NC}
		exit 0
	fi
fi
echo
#
echo ${BWhite}"Installing python-can"${NC}
pip install python-can > /dev/null 2>&1
if [ $? -eq 0 ]; then
	echo ${GREEN}"Successfully"${NC}
else
	echo ${RED}"NOT installed"${NC}
	exit 0
fi
echo
#
#
##############################################
#               INSTALL SAMBA                #
##############################################
echo "samba-common samba-common/workgroup string  WORKGROUP" | sudo debconf-set-selections
echo "samba-common samba-common/dhcp boolean true" | sudo debconf-set-selections
echo "samba-common samba-common/do_debconf boolean true" | sudo debconf-set-selections
echo ${BWhite}"Installing samba"${NC}
apt install -y samba > /dev/null 2>&1
if [ $? -eq 0 ]; then
	if grep -Fxq 'path = /home/pi/' '/etc/samba/smb.conf'; then
		echo ${GREEN}"Successfully"${NC}
	else
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
	echo ${GREEN}"Successfully"${NC}
	fi
	service smbd restart	
else
	echo ${RED}"NOT installed"${NC}
	exit 0
fi
echo
#
#
##############################################
#             INSTALL SKIN RNS*              #
##############################################
if (systemctl -q is-active kodi.service); then
	echo ${BWhite}"STOP Kodi"${NC}
	systemctl stop kodi.service
	sleep 10
elif (systemctl -q is-active kodi.service); then
	echo ${BWhite}"STOP Kodi (+10sec.)"${NC}
	systemctl stop kodi.service
	sleep 10
exit 1
fi
echo
##############################################
#             INSTALL SKIN RNSD              #
##############################################
if [ -e /boot/skin.rnsd*.zip ] ; then
	#rm -r /home/pi/.kodi/addons/skin.rns*
	unzip /boot/skin.rnsd*.zip -d /home/pi/.kodi/addons/ > /dev/null 2>&1
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
	systemctl enable tvtuner.service > /dev/null 2>&1
	sed -i -e '$i \  <addon optional="true">skin.rnsd</addon>' /usr/share/kodi/system/addon-manifest.xml
	sed -i 's/lookandfeel.skin" default="true">skin.estuary/lookandfeel.skin">skin.rnsd/' /home/pi/.kodi/userdata/guisettings.xml
	echo ${GREEN}"SKIN.RNSD INSTALLED BY DEFAULT"${NC}

##############################################
#             INSTALL SKIN RNSE              #
##############################################
elif [ -e /boot/skin.rnse*.zip ] ; then
	unzip /boot/skin.rnse*.zip -d /home/pi/.kodi/addons/ > /dev/null 2>&1
	sed -i -e '$i \  <addon optional="true">skin.rnse</addon>' /usr/share/kodi/system/addon-manifest.xml
	sed -i 's/lookandfeel.skin" default="true">skin.estuary/lookandfeel.skin">skin.rnse/' /home/pi/.kodi/userdata/guisettings.xml
	echo ${GREEN}"SKIN.RNSE INSTALLED BY DEFAULT"${NC}
fi
echo
#
#
mkdir /home/pi/movies /home/pi/music /home/pi/mults /home/pi/clips
chmod -R 0777 /home/pi/movies /home/pi/music /home/pi/mults /home/pi/clips
echo ${GREEN}"Successfully created media folder"${NC}
echo
#
#
##############################################
#                SETTINGS KODI               #
##############################################
cat <<'EOF' > /home/pi/.kodi/userdata/sources.xml
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
echo ${GREEN}"Add media sources /home/pi/"${NC}

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
echo ${GREEN}"Enable web-server"${NC}& echo http://${IP}:8080/

# Disable versioncheck
sed -i '/service.xbmc.versioncheck/d' /usr/share/kodi/system/addon-manifest.xml
echo
#
#
##############################################
#               INSTALL USBMOUNT             #
##############################################
if grep -Fxq 'VERSION="10 (buster)"' '/etc/os-release'; then
	echo ${BWhite}"install usbmount"${NC}
	apt install -y usbmount > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
		mkdir /home/pi/tmpu && cd /home/pi/tmpu
		wget https://github.com/nicokaiser/usbmount/releases/download/0.0.24/usbmount_0.0.24_all.deb > /dev/null 2>&1
		dpkg -i usbmount_0.0.24_all.deb > /dev/null 2>&1
		cd /home/pi && rm -Rf /home/pi/tmpu
		# add cirilic and UTF-8
		sed -i 's/FS_MOUNTOPTIONS=""/FS_MOUNTOPTIONS="-fstype=vfat,iocharset=utf8,gid=1000,dmask=0007,fmask=0007"/' /etc/usbmount/usbmount.conf
		sed -i 's/FILESYSTEMS="vfat ext2 ext3 ext4 hfsplus"/FILESYSTEMS="vfat ext2 ext3 ext4 hfsplus ntfs fuseblk"/' /etc/usbmount/usbmount.conf
		echo ${GREEN}"Successfully"${NC}
	else
		echo ${RED}"NOT installed"${NC}
		exit 0
	fi
fi
echo
#
#
##############################################
#         INSTALL BLUETOOTHE RECIEVER        #
##############################################
echo -n ${BWhite}"INSTALL BLUETOOTHE RECIEVER ? yes / no "${NC}
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
	hostnamectl set-hostname --pretty "rns"
	apt install -y --no-install-recommends pulseaudio > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
		echo ${GREEN}"Successfully install PulseAudio"${NC}
	else
		echo ${RED}"NOT install PulseAudio"${NC}
		exit 0
	fi
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
	systemctl enable --now pulseaudio.service > /dev/null 2>&1
	systemctl --global mask pulseaudio.socket
	apt install -y --no-install-recommends bluez-tools pulseaudio-module-bluetooth > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
		echo ${GREEN}"Successfully install pulseaudio-module-bluetooth"${NC}
	else
		echo ${RED}"NOT install pulseaudio-module-bluetooth"${NC}
		exit 0
	fi
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
	systemctl enable bt-agent@hci0.service > /dev/null 2>&1
	usermod -a -G bluetooth pulse

	# PulseAudio settings add after load-module module-position-event-sounds
	if grep -Fxq 'module-bluetooth-discover' '/etc/pulse/system.pa'; then
		echo
	else
		echo "load-module module-bluetooth-policy" >> /etc/pulse/system.pa
		echo "load-module module-bluetooth-discover" >> /etc/pulse/system.pa
	fi


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
	echo ${GREEN}"Successfully install bluetooth reciever"${NC}
#   BluetoothManager          #
	unzip /home/pi/.kodi/addons/skin.rns*/resources/Bluetooth*.zip -d /home/pi/.kodi/addons/ > /dev/null 2>&1
	sed -i -e '$i \  <addon optional="true">script.bluetooth.man</addon>' /usr/share/kodi/system/addon-manifest.xml
	
fi
echo
#
#
##############################################
#            EDIT /boot/config.txt           #
##############################################
echo -n ${BWhite}"Use HDMI to VGA adapter ? yes / no "${NC}
read answer
if [ "$answer" != "${answer#[Y|y]}" ]; then
	mv /boot/config.txt /boot/config.txt_original
	# OS BULLSEYE #
	if grep -Fxq 'VERSION="11 (bullseye)"' '/etc/os-release'; then
		cat <<'EOF' > /boot/config.txt
# HDMI to VGA adapter for RNS
hdmi_force_hotplug=1
disable_overscan=1
dtoverlay=vc4-fkms-v3d
hdmi_ignore_edid=0xa5000080
hdmi_group=2
hdmi_mode=87
hdmi_timings 800 0 51 44 121 460 0 10 9 14 0 0 0 32 1 16000000 3
framebuffer_width=400
framebuffer_height=230

# Enable MCP2515 CanBus
dtparam=spi=on
dtoverlay=mcp2515-can0,oscillator=8000000,interrupt=25
dtoverlay=spi-bcm2835-overlay

EOF
	elif grep -Fxq 'VERSION="10 (buster)"' '/etc/os-release'; then
		cat <<'EOF' > /boot/config.txt
# HDMI to VGA adapter for RNS
hdmi_force_hotplug=1
disable_overscan=1
hdmi_ignore_edid=0xa5000080
hdmi_group=2
hdmi_mode=87
hdmi_timings 800 0 51 44 121 460 0 10 9 14 0 0 0 32 1 16000000 3
framebuffer_width=400
framebuffer_height=230

# Enable MCP2515 CanBus
dtparam=spi=on
dtoverlay=mcp2515-can0,oscillator=8000000,interrupt=25
dtoverlay=spi-bcm2835-overlay

EOF
	fi
else
	mv /boot/config.txt /boot/config.txt_original
	# OS BULLSEYE #
	if grep -Fxq 'VERSION="11 (bullseye)"' '/etc/os-release'; then
		cat <<'EOF' > /boot/config.txt
# Video output Analog 3,5mm composite PAL
sdtv_mode=2
dtoverlay=vc4-kms-v3d

# Enable MCP2515 CanBus
dtparam=spi=on
dtoverlay=mcp2515-can0,oscillator=8000000,interrupt=25
dtoverlay=spi-bcm2835-overlay

EOF
	elif grep -Fxq 'VERSION="10 (buster)"' '/etc/os-release'; then
		cat <<'EOF' > /boot/config.txt
# Video output Analog 3,5mm composite PAL
sdtv_mode=2

# Enable MCP2515 CanBus
dtparam=spi=on
dtoverlay=mcp2515-can0,oscillator=8000000,interrupt=25
dtoverlay=spi-bcm2835-overlay

EOF
	fi
fi
echo
#
#
##############################################
#         ADD HiFiberry DAC PCM5102          #
##############################################
echo -n ${BWhite}"Use HiFiberry DAC (PCM5102) ? yes / no "${NC}
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
	cat <<'EOF' >> /boot/config.txt
# Enable audio 
dtoverlay=hifiberry-dac
EOF
else
	cat <<'EOF' >> /boot/config.txt
# Enable audio 3,5mm
dtparam=audio=on
EOF
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
