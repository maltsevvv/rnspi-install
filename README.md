## Установка ПО для Audi Navigation Plus RNS-D и RNS-E (RNSPI)
![prototype scheme](https://github.com/maltsevvv/rnspi-install/blob/main/img/rnsd.png)
![prototype scheme](https://github.com/maltsevvv/rnspi-install/blob/main/img/rnse.png)



## Auto Install

Записать на sd-карту с образом Raspbian Buster Lite
	https://downloads.raspberrypi.org/raspbian/images/raspbian-2019-07-12/

Cкопировать  на sd-карту в /boot/
	`skin.rnsd-main.zip` или `skin.rnse-main.zip`

Вставить SD карту в Raspberry и подключить MCP2515 canbus модуль

Подключиться к Raspberry, по SSH  
`login: pi`  
`password: rpi` (или Ваш. Ввод пароля не отображается)

	cd /tmp
	wget -q https://github.com/maltsevvv/rnspi-install/archive/main.zip
	unzip main.zip
	cd rnspi-install-main
	sudo sh install.sh


*Если используете USB Bluetoothe модуль, то его необходимо подключать вручную. После установки этого скрипта*

	sudo bluetoothctl
	scan on

*Находим свой телефон*

	pair 5C:10:C5:E0:94:A6 
	Request PIN code  
	[agent] Enter PIN code: `1234`  
	exit



##Manual Install

Edit /boot/config.txt
  
	sudo nano /boot/config.txt

*insert*

	# HDMI to VGA adapter 
	hdmi_group=1
	hdmi_mode=6

	# Enable MCP2515 can0
	dtparam=spi=on
	dtoverlay=mcp2515-can0,oscillator=8000000,interrupt=25
	dtoverlay=spi-bcm2835-overlay

	# Enable audio (loads snd-hifiberry) and comment #dtparam=audio=on
	dtoverlay=hifiberry-dac

	# Enable video core & MPEG
	gpu_mem=128
	start_x=1

Update and upgrade

	sudo apt update
	sudo apt upgrade -y
	
Install KODI

	sudo apt install -y kodi

Upstart KODI
	
	sudo nano /etc/systemd/system/kodi.service  
*insert*

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

Enable and Start service
	
	sudo systemctl enable kodi.service
	sudo systemctl start kodi.service

Creating directories for storing media files

	sudo mkdir /home/pi/movies /home/pi/music /home/pi/mults
	sudo chmod -R 0777 /home/pi/movies /home/pi/music /home/pi/mults`

Install SAMBA

	sudo apt install -y samba
	sudo nano /etc/samba/smb.conf
	
*insert at the end of the file*

	[rns]
	path = /home/pi/
	create mask = 0775
	directory mask = 0775
	writeable = yes
	browseable = yes
	public = yes
	force user = root
	guest ok = yes

Reboot service

	sudo service smbd restart 

Install usbmount

	sudo apt install -y usbmount
	mkdir /home/pi/tmpu && cd /home/pi/tmpu
	wget https://github.com/nicokaiser/usbmount/releases/download/0.0.24/usbmount_0.0.24_all.deb
	sudo dpkg -i usbmount_0.0.24_all.deb
	cd /home/pi 
	rm -r tmpu 
	sudo sed -i 's/FS_MOUNTOPTIONS=""/FS_MOUNTOPTIONS="-fstype=vfat,iocharset=utf8,gid=1000,dmask=0007,fmask=0007"/' /etc/usbmount/usbmount.conf
	
Install can-utils & python-pip

	sudo apt install python-pip can-utils  
	sudo pip install python-can


Install *skin.rnsd.zip* or *skin.rnse.zip* in KODI"

##Emulate TV tuner for RNSD

Copy from folder skin.rnsd to /usr/local/bin/

	sudo cp /home/pi/.kodi/addons/skin.rnsd/tvtuner.pyo /usr/local/bin/

Upstart tvtuner

	sudo nano /etc/systemd/system/tvtuner.service

*insert*

	[Unit]
	Description=Emulation tv-tuner 4BO919146B for RNSD
	[Service]
	Type=simple
	ExecStart=/usr/bin/python /usr/local/bin/tvtuner.pyo
	Restart=always
	[Install]
	WantedBy=multi-user.target

Enable & Start service

	sudo systemctl enable tvtuner.service
	sudo systemctl start tvtuner.service




#If you need to connect a second canbus 

Edit /boot/config.txt
  
	sudo nano /boot/config.txt

*insert*

	# Enable MCP2515 can1
	cd /boot/overlays
	wget https://github.com/maltsevvv/rnspi-install/raw/main/img/mcp2515-can1-0.dtbo	
	dtoverlay=spi1-1cs,cs0_pin=16	
	dtoverlay=mcp2515,spi1-0,oscillator=8000000,interrupt=12	

*connect MCP2515 - Raspberry*

int : GPIO12  
sck : GPIO21  
si  : GPIO20  
so  : GPIO19  
cs  : GPIO16
