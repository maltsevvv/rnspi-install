## Установка ПО для Audi Navigation Plus RNS-D и RNS-E (RNSPI)
![prototype scheme](https://github.com/maltsevvv/rnspi-install/blob/main/img/rnsd.png)
![prototype scheme](https://github.com/maltsevvv/rnspi-install/blob/main/img/rnse.png)



## Auto Install
```
wget -P /tmp https://raw.githubusercontent.com/maltsevvv/rnspi-install/main/install.sh
sudo sh /tmp/install.sh
```

### Manual Install
[Raspbian Bullseye Kodi 19](https://github.com/maltsevvv/rnspi-install/blob/main/manual%20install%20for%20Raspbian%20Bullseye.md#manual-install-if-you-using-raspbian-bullseye-kodi-19)  
[Raspbian Buster Kodi 18](https://github.com/maltsevvv/rnspi-install/blob/main/manual%20install%20for%20Raspbian%20Buster.md#manual-install-if-you-using-raspbian-buster-kodi-18)
[Connect Bluetooth for Kodi 18](https://github.com/maltsevvv/rnspi-install/blob/main/manual%20install%20for%20Raspbian%20Buster.md#usb-bluetoothe-%D0%BC%D0%BE%D0%B4%D1%83%D0%BB%D1%8C)


#### Для подключения 2-ого MCP2515 can модуля
```
cd /boot/overlays
wget https://github.com/maltsevvv/rnspi-install/raw/main/img/mcp2515-can1-0.dtbo
```
```
sudo nano /boot/config.txt
```
```
# Enable MCP2515 can1
dtoverlay=spi1-1cs,cs0_pin=16	
dtoverlay=mcp2515,spi1-0,oscillator=8000000,interrupt=12	
```
*connect MCP2515 - Raspberry*

int : GPIO12  
sck : GPIO21  
si  : GPIO20  
so  : GPIO19  
cs  : GPIO16
