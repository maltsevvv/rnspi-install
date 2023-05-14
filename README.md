<h1 align="center"> <a href="https://sites.google.com/view/rnspi/"target="_blank">Skin Kodi for RNSD or RNSE</a>
<h1 align="center">Alternative replacement: CD-Changer, TV-tuner</h1>
<h3 align="center"><img src="https://github.com/maltsevvv/rnspi-install/blob/main/img/rnsd.png"><img src="https://github.com/maltsevvv/rnspi-install/blob/main/img/rnse.png"</h3>

## Auto Install
 
```
wget -P /tmp https://raw.githubusercontent.com/maltsevvv/rnspi-install/main/install.sh
sudo sh /tmp/install.sh
```

### Manual Install
[Raspbian Bullseye Kodi 19](https://github.com/maltsevvv/rnspi-install/blob/main/manual%20install%20for%20Raspbian%20Bullseye.md#manual-install-if-you-using-raspbian-bullseye-kodi-19)  
[Raspbian Buster Kodi 18](https://github.com/maltsevvv/rnspi-install/blob/main/manual%20install%20for%20Raspbian%20Buster.md#manual-install-if-you-using-raspbian-buster-kodi-18)  
[Connect Bluetooth for Kodi 18](https://github.com/maltsevvv/rnspi-install/blob/main/manual%20install%20for%20Raspbian%20Buster.md#usb-bluetoothe-%D0%BC%D0%BE%D0%B4%D1%83%D0%BB%D1%8C)

## [Downloads skin Kodi](https://github.com/maltsevvv/rnspi-install/tree/901cde9e8235d21487f509bb3487f4a7ec8c67cb/share)  
#### If you want to install skin not on raspberry `Settings-> Add-ons-> Get Add-ons-> Install from zip file`


#### Connect to WIFI:  
Copy to SD-card в `/boot` [wpa_supplicant.conf](https://github.com/maltsevvv/rnspi-install/blob/035eabf01159378c28eaf0b3793232733d6ed31e/share/wpa_supplicant.conf)     

    ssid="NAME"
    psk="PASSWORD"


### [CAN bus commands](https://github.com/maltsevvv/rnspi-install/blob/e6c6dae49056ac5a839e0b212b30da1c50cfdde5/canbus.md)  


#### Dual MCP2515 CAN Interfaces
 
https://forums.raspberrypi.com/viewtopic.php?t=330013
https://github.com/raspberrypi/linux/issues/1804
