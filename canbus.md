# Команды для CanBus

### Включение интрфейса:
```
sudo /sbin/ip link set can0 up type can bitrate 100000
```
### Отключение интрфейса:
```
sudo /sbin/ip link set can0 down
```

### Проверяем сетевой интерфейс:
```
ifconfig
```
*Должны получить, что-то вроде*  
`can0: flags=193<UP,RUNNING,NOARP>  mtu 16`  
`       unspec 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  txqueuelen 10  (UNSPEC)`  
`       RX packets 82804  bytes 436820 (426.5 KiB)`    
`       RX errors 1  dropped 63269  overruns 0  frame 1`       
`       TX packets 0  bytes 0 (0.0 B) `        
`       TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0`

### Тестирование MCP2515 (проверка работоспособности)
```
sudo ip link set can0 up type can bitrate 100000 loopback on
```
```
cangen can0
 ```
 #### в другом терминале вводим
 ```
candump can0
```
*В ответ должны получать сообщения типа*  
`(1683996205.089064)  can0  002   [8]  FF FF FF FF FF FF FF FF`  
 `(1683996205.097864)  can0  112   [8]  54 56 2F 56 49 44 45 4F`  


### Просмотр сообщений в кан шине:
```
candump can0
```
### Просмотр сообщений в кан шине с фильтром по ID:
```
candump can0,123:7ff,456:7ff
```
#### Просмотр сообщений в кан шине с фильтром отображения
```
candump -c -c -ta can0,341:7FF
```
` (1683996196.273203)  can0  765   [8]  FF FF FF FF FF FF FF FF`
```
candump -c -c -a can0,341:7FF
```
` can0  765   [8]  54 56 2F 56 49 44 45 4F   'TV/VIDEO'`
### Отправка сообщений в кан шину:
```
cansend can0 123#11223344AABBCCDD
```
### Cохранение сообщений кан шины в log:
```
candump -l can0
```
### Воспроизвести cохраненные сообщения из log:
```
canplayer -I имя_созданого_лога.log
```
### Поиск изменяющихся данных:
```
cansniffer can0 -c
```
