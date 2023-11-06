## MANUAL INSTALL IF You using Raspbian Buster Kodi 18

Edit /boot/config.txt
  
```
sudo nano /boot/config.txt
```
```
# HDMI to VGA adapter
hdmi_group=1
hdmi_mode=6

# Enable MCP2515 can0
dtparam=spi=on
dtoverlay=mcp2515-can0,oscillator=8000000,interrupt=25
dtoverlay=spi-bcm2835-overlay

# Enable audio (loads snd-hifiberry)
#dtparam=audio=on
dtoverlay=hifiberry-dac
```

# UPDATE
```
sudo apt update
```

# INSTALL KODI
```
sudo apt install -y kodi
```
```
sudo nano /etc/systemd/system/kodi.service
```
```
[Unit]
Description = Kodi Media Center
[Service]
User = pi
Group = pi
Type = simple
ExecStart = /usr/bin/kodi-standalone
Restart = always
RestartSec = 15
[Install]
WantedBy = multi-user.target
```
```
sudo systemctl enable kodi.service
sudo systemctl start kodi.service
```

# CREATING MEDIA FOLDERS
```
sudo mkdir /home/pi/movies /home/pi/music /home/pi/mults
sudo chmod -R 0777 /home/pi/movies /home/pi/music /home/pi/mults
```

# INSTALL SAMBA
```
sudo apt install -y samba
```
```
sudo nano /etc/samba/smb.conf
```
```
[rns]
path = /home/pi/
create mask = 0775
directory mask = 0775
writeable = yes
browseable = yes
public = yes
force user = root
guest ok = yes
```
```
sudo service smbd restart 
```

# INSTALL USBMOUNT
```
sudo apt install -y usbmount
```
```
mkdir /home/pi/tmpu && cd /home/pi/tmpu
wget https://github.com/nicokaiser/usbmount/releases/download/0.0.24/usbmount_0.0.24_all.deb
sudo dpkg -i usbmount_0.0.24_all.deb
cd /home/pi 
rm -r tmpu 
```
```
sudo sed -i 's/FS_MOUNTOPTIONS=""/FS_MOUNTOPTIONS="-fstype=vfat,iocharset=utf8,gid=1000,dmask=0007,fmask=0007"/' /etc/usbmount/usbmount.conf 
sudo sed -i 's/FILESYSTEMS="vfat ext2 ext3 ext4 hfsplus"/FILESYSTEMS="vfat ext2 ext3 ext4 hfsplus ntfs fuseblk"/' /etc/usbmount/usbmount.conf
```

# INSTALL FOR CANBUS
```
sudo apt install -y can-utils  
```
```
sudo apt install -y python-pip
```
```
sudo pip install python-can
```
```
sudo nano /etc/network/interfaces
```
```
auto can0
  iface can0 inet manual
  pre-up /sbin/ip link set can0 type can bitrate 100000
  up /sbin/ifconfig can0 up
  down /sbin/ifconfig can0 down
```


# INSTALL SKIN IN KODI
*Settings/Add-ons/Install from zip file*
`skin.rnsd.zip` or `skin.rnse.zip`

## Emulate TV tuner for RNSD
```
sudo cp /home/pi/.kodi/addons/skin.rnsd/tvtuner.pyo /usr/local/bin/
```
```
sudo nano /etc/systemd/system/tvtuner.service
```
```
[Unit]
Description=Emulation tv-tuner 4BO919146B for RNSD
[Service]
Type=simple
ExecStart=/usr/bin/python /usr/local/bin/tvtuner.pyo
Restart=always
[Install]
WantedBy=multi-user.target
```
```
sudo systemctl enable tvtuner.service
sudo systemctl start tvtuner.service
```

# INSTALL BLUETOOTHE RECIEVER
```
sudo hostnamectl set-hostname --pretty "rns" 
```
```
sudo apt install -y --no-install-recommends pulseaudio
```
```
sudo usermod -a -G pulse-access root
sudo usermod -a -G bluetooth pulse
```
```
sudo mv /etc/pulse/client.conf /etc/pulse/client.conf.orig
```
```
sudo nano /etc/pulse/client.conf
```
```
default-server = /run/pulse/native
autospawn = no
```
```
sed -i '/^load-module module-native-protocol-unix$/s/$/ auth-cookie-enabled=0 auth-anonymous=1/' /etc/pulse/system.pa
```
#### PulseAudio system daemon
```
sudo nano /etc/systemd/system/pulseaudio.service
```
```
[Unit]
Description=Sound Service
[Install]
WantedBy=multi-user.target
[Service]
Type=notify
PrivateTmp=true
ExecStart=/usr/bin/pulseaudio --daemonize=no --system --disallow-exit --disable-shm --exit-idle-time=-1 --log-target=journal --realtime --no-cpu-limit
Restart=on-failure
```
```
sudo systemctl enable --now pulseaudio.service
sudo systemctl --global mask pulseaudio.socket
```
```
sudo apt install -y --no-install-recommends bluez-tools pulseaudio-module-bluetooth
```
#### Bluetooth settings
```
sudo nano /etc/bluetooth/main.conf
```
```
[General]
Class = 0x200414
DiscoverableTimeout = 0

[Policy]
AutoEnable=true
```

#### Make Bluetooth discoverable after initialisation
```
sudo mkdir -p /etc/systemd/system/bthelper@.service.d
```
```
sudo nano /etc/systemd/system/bthelper@.service.d/override.conf
[Service]
Type=oneshot
```
```
sudo nano /etc/systemd/system/bt-agent@.service
```
```
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
```
```
sudo systemctl daemon-reload
sudo systemctl enable bt-agent@hci0.service
sudo usermod -a -G bluetooth pulse
```
#### PulseAudio settings
```
sudo nano /etc/pulse/system.pa
```
```
load-module module-bluetooth-policy
load-module module-bluetooth-discover
```
#### Bluetooth udev script
```
sudo nano /usr/local/bin/bluetooth-udev
```
```
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
```
```
sudo chmod 755 /usr/local/bin/bluetooth-udev
```
```
sudo nano /etc/udev/rules.d/99-bluetooth-udev.rules
```
```
SUBSYSTEM=="input", GROUP="input", MODE="0660"
KERNEL=="input[0-9]*", RUN+="/usr/local/bin/bluetooth-udev"
```
#### add in /etc/asound.conf
```
sudo nano /etc/asound.conf
```
```
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
```

```
sudo reboot
```

# USB Bluetoothe модуль V5
```
hciconfig
hci1:   Type: Primary  Bus: USB
        BD Address: E4:5F:01:81:78:7F  ACL MTU: 1021:8  SCO MTU: 64:1
        DOWN RUNNING
        RX bytes:823 acl:0 sco:0 events:54 errors:0
        TX bytes:2763 acl:0 sco:0 commands:54 errors:0

```
* Обновляем *

```
sudo systemctl disable hciuart
sudo modprobe btusb
sudo rpi-update
```

* USB Bluetoothe модуль V5, необходимо подключать вручную*

# USB Bluetoothe модуль
*Если используете USB Bluetoothe модуль, то его необходимо подключать вручную*

`sudo bluetoothctl`

`scan on`

*Находим MAC своего телефон* 

`pair 5C:10:C5:E0:94:A6`

`connect 5C:10:C5:E0:94:A6`

`trust 5C:10:C5:E0:94:A6`

`Request PIN code`

`[agent] Enter PIN code: 1234`
	
`exit`

--------------------------------
*Для удаления сопряжения с устройством*

`sudo bluetoothctl`

`paired-devices`

*Видим MAC всех сопряжений* 

`untrust 5C:10:C5:E0:94:A6`

`remove 5C:10:C5:E0:94:A6`

`exit`
