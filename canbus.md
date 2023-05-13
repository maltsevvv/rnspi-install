# Работа с CanBus

### Включение интрфейса:
```
sudo /sbin/ip link set can0 up type can bitrate 100000
```
### Отключение интрфейса:
```
sudo /sbin/ip link set can0 down
```

## ПРОВЕРЯЕМ СЕТЕВОЙ ИНТЕРФЕЙС:
```
ifconfig
```
ответ такой, должен быть
*can0: flags=193<UP,RUNNING,NOARP>  mtu 16
        unspec 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  txqueuelen 10  (UNSPEC)
        RX packets 82804  bytes 436820 (426.5 KiB)
        RX errors 1  dropped 63269  overruns 0  frame 1
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0*

### Тестирование MCP2515
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
В ответ должны получать сообщения типа
*(1683996205.089064)  can0  341   [8]  FF FF FF FF FF FF FF FF
 (1683996205.097864)  can0  341   [8]  54 56 2F 56 49 44 45 4F*
Если все так, то все OK.

### Просмотр шины Can0:
```
candump can0
```
### Отправка в Can0:
```
cansend can0 123#11223344AABBCCDD
```
### Фильтр по ID
```
candump can0,123:7ff,456:7ff
```
### Cохранение candump в log:
```
candump -l can0
```
### Воспроизвести log:
```
canplayer -I имя_созданого_лога.log
```

### Примеры
```
candump -c -c -ta can0,341:7FF
```
` (1683996196.273203)  can0  765   [8]  FF FF FF FF FF FF FF FF`
```
candump -c -c -a can0,341:7FF
```
` can0  765   [8]  54 56 2F 56 49 44 45 4F   'TV/VIDEO'`

