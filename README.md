## Установка ПО для Audi Navigation Plus RNS-D и RNS-E (RNSPI)
![prototype scheme](https://github.com/maltsevvv/rnspi-install/blob/main/img/rnsd.png)
![prototype scheme](https://github.com/maltsevvv/rnspi-install/blob/main/img/rnse.png)


# Auto Install

***1. Записать на sd-карту с образом Raspbian Buster Lite***

	https://downloads.raspberrypi.org/raspbian/images/raspbian-2019-07-12/

***2. Cкопировать  на sd-карту в /boot/***

	skin.rnsd-main.zip
	skin.rnse-main.zip

***3. Вставить SD карту в Raspberry и подключить MCP2515 canbus модуль***

***4. Подключиться к Raspberry, по SSH***

	login: pi
	password: rpi (или Ваш)
	
	cd /tmp  
	wget -q https://github.com/maltsevvv/rnspi-install/archive/main.zip  
	unzip main.zip  
	cd rnspi-install-main  
	sudo sh install.sh  


### Если используете USB Bluetoothe модуль, то его необходимо подключить вручную. После установки этого скрипта

	sudo bluetoothctl  
	scan on  

***находим свой телефон***
	pair 5C:10:C5:E0:94:A6 
	Request PIN code  
	[agent] Enter PIN code: `1234`  
	exit



# Manual Install

***edit /boot/config.txt***
  
	sudo nano /boot/config.txt
	
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

***UPDATE***

	sudo apt update
	sudo apt upgrade -y
	
***INSATALL KODI***

	sudo apt install -y kodi

***Добавить автозагрузку для  KODI***
	
	sudo nano /etc/systemd/system/kodi.service
	
****Вставить****

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

***Активировать сервич и запустить KODI***
	
	sudo systemctl enable kodi.service
	sudo systemctl start kodi.service

***Создать каталоги для хранения медиа файлов***

	sudo mkdir /home/pi/movies /home/pi/music /home/pi/mults
	sudo chmod -R 0777 /home/pi/movies /home/pi/music /home/pi/mults`


***Установить usbmount (для автоподключения usb дисков)

	sudo apt install -y usbmount
	mkdir /home/pi/tmpu && cd /home/pi/tmpu
	wget https://github.com/nicokaiser/usbmount/releases/download/0.0.24/usbmount_0.0.24_all.deb
	sudo dpkg -i usbmount_0.0.24_all.deb
	cd /home/pi && rm -Rf /home/pi/tmpu 
	sed -i 's/FS_MOUNTOPTIONS=""/FS_MOUNTOPTIONS="-fstype=vfat,iocharset=utf8,gid=1000,dmask=0007,fmask=0007"/' /etc/usbmount/usbmount.conf
	
***Установить can-utils python-pip***

	sudo apt install python-pip
	sudo apt install can-utils  
	sudo pip install python-can

## Установить ***skin.rnsd.zip*** или ***skin.rnse.zip*** в KODI через "Установить дополнение из zip"



## Эмулировать тв-тюнер для RNSD

***Копируем из папки skin.rnsd в /usr/local/bin/***

	cp /home/pi/.kodi/addons/skin.rnsd/tvtuner.pyo /usr/local/bin/

***Создаем файл для автозапуска***

	sudo nano /etc/systemd/system/tvtuner.service

***Вставить***

	[Unit]
	Description=Emulation tv-tuner 4BO919146B for RNSD
	[Service]
	Type=simple
	ExecStart=/usr/bin/python /usr/local/bin/tvtuner.pyo
	Restart=always
	[Install]
	WantedBy=multi-user.target

# Активировать сервис и запустить тв-тюнер

	sudo systemctl enable tvtuner.service
	sudo systemctl start tvtuner.service
	


## Эмулировать тв-тюнер для RNSE, через интерфейс. После ввода пароля


### Устаеовить SAMBA (файловый сервер, для копирования по локальной сети)

	sudo apt install -y samba
	sudo nano /etc/samba/smb.conf
	
***Вставить. В самом конце файла***

	[rns]
	path = /home/pi/
	create mask = 0775
	directory mask = 0775
	writeable = yes
	browseable = yes
	public = yes
	force user = root
	guest ok = yes

***Перезапустить сервер. После перезапуска можно попасть на Raspberry с другого ПК \\localhost***

	sudo service smbd restart`  


### Подключение canbus2 can1

	sudo nano /boot/config.txt`
	# Enable MCP2515 can1
	cd /boot/overlays
	wget https://github.com/maltsevvv/rnspi-install/raw/main/img/mcp2515-can1-0.dtbo	
	dtoverlay=spi1-1cs,cs0_pin=16	
	dtoverlay=mcp2515,spi1-0,oscillator=8000000,interrupt=12	

int : GPIO12  
sck : GPIO21  
si  : GPIO20  
so  : GPIO19  
cs  : GPIO16
