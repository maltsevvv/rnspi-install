<h1 align="center"> <a href="https://sites.google.com/view/rnspi/"target="_blank">Skin Kodi for RNSD or RNSE</a>
<h1 align="center">Alternative replacement: CD-Changer, TV-tuner</h1>
<h3 align="center"><img src="https://github.com/maltsevvv/rnspi-install/blob/main/img/rnsd.png"><img src="https://github.com/maltsevvv/rnspi-install/blob/main/img/rnse.png"</h3>

## Auto Install  
> 1. Burning Raspbian Image to SD Card  (Rasbian Buster Lite or Rasbian Bullseye x32 Lite)
> 2. Copy the skin.rns*.zip to the SD card, to the */boot* partition  
<div id="badges">
  <a href="https://github.com/maltsevvv/rnspi-install/tree/901cde9e8235d21487f509bb3487f4a7ec8c67cb/share">
    <img src="https://img.shields.io/badge/Free_skin-blue?style=for-the-badge&logo=Kodi&logoColor=white" alt="Free_skin Badge"/>
  </a>
  <a href="https://telegram.me/maltsev_v_v">
    <img src="https://img.shields.io/badge/15$_skin_telegram-blue?style=for-the-badge&logo=Telegram&logoColor=white" alt="Buy_skin_telegram Badge"/>
  </a>
  <a href="mailto:maltsev.v.v@hotmail.com">
    <img src="https://img.shields.io/badge/15$_skin_Email-blue?style=for-the-badge&logo=Email&logoColor=white" alt="Buy_skin_Email Badge"/>
  </a>
</div>
   
> 3. Insert SD card into raspberry  
   connect power  
   connect to raspberry via SSH, via putty  
 
```
wget -P /tmp https://raw.githubusercontent.com/maltsevvv/rnspi-install/main/install.sh
sudo sh /tmp/install.sh
```

### Manual Install
<div id="badges">
  <a href="https://github.com/maltsevvv/rnspi-install/blob/main/manual%20install%20for%20Raspbian%20Bullseye.md#manual-install-if-you-using-raspbian-bullseye-kodi-19">
    <img src="https://img.shields.io/badge/Raspbian_Bullseye_Kodi_19-blue?style=for-the-badge&logo=RaspberryPi&logoColor=white" alt="Raspbian_Bullseye_Kodi_19 Badge"/>
  </a>
  <a href="https://github.com/maltsevvv/rnspi-install/blob/main/manual%20install%20for%20Raspbian%20Buster.md#manual-install-if-you-using-raspbian-buster-kodi-18">
    <img src="https://img.shields.io/badge/Raspbian_Buster_Kodi_18-blue?style=for-the-badge&logo=RaspberryPi&logoColor=white" alt="Raspbian_Buster_Kodi_18 Badge"/>
  </a>
  <a href="https://github.com/maltsevvv/rnspi-install/blob/main/manual%20install%20for%20Raspbian%20Buster.md#usb-bluetoothe-%D0%BC%D0%BE%D0%B4%D1%83%D0%BB%D1%8C">
    <img src="https://img.shields.io/badge/Connect_Bluetooth_for_Kodi_18-blue?style=for-the-badge&logo=RaspberryPI&logoColor=white" alt="Connect_Bluetooth_for_Kodi_18 Badge"/>
  </a>
</div>
  
#### Install skin.rns*.zip `Settings-> Add-ons-> Get Add-ons-> Install from zip file`

--------------------------------------------------------------------------------------

#### Connect to WIFI:  
Copy to SD-card в `/boot/` [wpa_supplicant.conf](https://github.com/maltsevvv/rnspi-install/blob/035eabf01159378c28eaf0b3793232733d6ed31e/share/wpa_supplicant.conf)     

    ssid="my_wifi_ssid"
    psk="my_password"


### [CAN bus commands](https://github.com/maltsevvv/rnspi-install/blob/e6c6dae49056ac5a839e0b212b30da1c50cfdde5/canbus.md)  


 
#### Dual MCP2515 CAN Interfaces
 
https://forums.raspberrypi.com/viewtopic.php?t=330013  
https://github.com/raspberrypi/linux/issues/1804
