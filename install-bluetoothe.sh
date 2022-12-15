#!/bin/bash

# sudo sh install-bluetoothe.sh
BWhite='\033[1;37m'; RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m' # color
if
[ $(id -u) -ne 0 ]; then echo "Please run as root"; exit 1; fi
echo
####

echo -n ${BWhite}"INSTALL BLUETOOTHE RECIEVER (TEST) ? yes / no "${NC}
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

# Disable user-level PulseAudio service
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
	#sed -i.orig 's/^load-module module-udev-detect$/load-module module-udev-detect tsched=0/' /etc/pulse/system.pa
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

else

	# Disable Bluetooth
	if grep -Fxq 'dtoverlay=disable-bt' '/boot/config.txt'; then
		echo ${GREEN}"Invalid Bluetooth"${NC}
	else
		cat <<'EOF' >> /boot/config.txt
dtoverlay=disable-bt
EOF
		echo ${GREEN}"GPU 128MB"${NC}
	fi
fi

