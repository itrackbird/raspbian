### 概述

这是关于树莓派wifi的日常使用记录。

> **所有操作特指在树莓派3B型号操作，其他型号暂未实验**

### 功能

* wifi自动连接
* 热点wifi开启

### wifi自动连接

暂无

### 创建wifi热点

功能软件使用开源项目[create_app](https://github.com/oblique/create_ap)开启热点，在安装该软件包前，需要安装一些依赖包，如下操作

```she
root@raspberrypi:/home/pi# apt-get install util-Linux procps hostapd iproute2 iw haveged dnsmasq
```

安装完毕之后，下载代码代码到本地安装即可。

```she
root@raspberrypi:/# git clone https://github.com/oblique/create_ap
root@raspberrypi:/# tree create_ap/
create_ap/
├── bash_completion
├── create_ap
├── create_ap.conf
├── create_ap.service
├── howto
│   └── realtek.md
├── LICENSE
├── Makefile
└── README.md

1 directory, 8 files
```

当代码下载到本地后，使用`create_ap`脚本来开启热点。

```sh
root@raspberrypi:/create_ap# ./create_ap --no-virt wlan0 eth0 pzm-test 12345678
WARN: brmfmac driver doesn't work properly with virtual interfaces and
      it can cause kernel panic. For this reason we disallow virtual
      interfaces for your adapter.
      For more info: https://github.com/oblique/create_ap/issues/203
Config dir: /tmp/create_ap.wlan0.conf.CxDk3JTC
PID: 1393
Sharing Internet using method: nat
hostapd command-line interface: hostapd_cli -p /tmp/create_ap.wlan0.conf.CxDk3JTC/hostapd_ctrl
Configuration file: /tmp/create_ap.wlan0.conf.CxDk3JTC/hostapd.conf
Failed to create interface mon.wlan0: -95 (Operation not supported)
wlan0: Could not connect to kernel driver
Using interface wlan0 with hwaddr b8:27:eb:e4:d4:81 and ssid "pzm-test"
wlan0: interface state UNINITIALIZED->ENABLED
```

之后，手机就会看见一个wifi叫pzm-test，输入密码后就可以连接到该wifi。

> **使用`ifconfig`命令查看是否存在wlan0网卡，这是树莓派3的无线网卡，对于未存在情况未做实验**