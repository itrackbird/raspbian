### 概述

这是关于树莓派3B型号日常学习过程的记录文档。

### 操作系统

树莓派支持的操作系统有很多，如ubuntu、windows等，详情见[官方网址](https://www.raspberrypi.org/downloads/)，同时也支持CentOS系统，可以在[镜像地址](http://mirror.centos.org/altarch/7/isos/armhfp/)中下载centos镜像，以下记录默认是以centos为例。

### 安装系统

树莓派安装主要有三个步骤：

* 镜像ISO下载
* [TF卡格式化工具](https://www.sdcard.org/downloads/formatter_4/)(SD Card Fornatter)
* [Win32DiskImager](https://sourceforge.net/projects/win32diskimager/)烧录工具安装

首先格式化工具将TF卡格式化，目的是为了将TF卡文件系统刷成FAT32格式，之后打开win32DiskImager选择镜像文件导入到TF卡中，等结束之后，将TF卡插入树莓派中，上电重启即可。

> **提示：需要从电脑中安全拔出TF卡，以防止TF卡损坏导致树莓派违法识别TF卡**

### 登录系统

当我们安装完系统后，可以通过图形界面操作或者命令行操作，以下操作是以通过命令行操作，步骤有两步：

* 获取IP
* ssh登录

#### 获取IP

首先我们需要一个连接wifi的电脑和一根网线，右键查看**'网络'**属性，在活动网络中可以看到本机连接的WIFI名称，点击之后，查看**'属性'**，最后在**'共享'**中勾选允许其他网络用户通过此计算机的Internet连接。然后拿一根网线连接PC机和树莓派网口，上电启动树莓派，等待树莓派启动完成，在PC机上打开powershell，输入`arp -a`就可以看到多出了一个接口，在里面就包含了树莓派的IP。

```powershell
PS C:\Users\Administrator> arp -a

接口: 192.168.1.103 --- 0xb
  Internet 地址         物理地址              类型
  192.168.1.1           
  192.168.1.255         

接口: 192.168.137.1 --- 0xc
  Internet 地址         物理地址              类型
  192.168.137.33      #树莓派地址  
  192.168.137.255     #网关
```

#### ssh登录

在我们获取到了树梅派系统的IP之后就可以通过终端软件xshell连接到系统中，默认用户名密码为root/centos。当我们登录到系统后，`df -h`查看发现只有一个G磁盘大小，这时我们需要扩展下文件系统，执行`/usr/bin/rootfs-expand`即可解决该问题。

> **扩展文件系统命令`/usr/bin/rootfs-expand`在家目录下面的README有具体介绍**

```SHE
[root@centos-rpi3 ~]# cat README
== CentOS 7 userland ==

If you want to automatically resize your / partition, just type the following (as root user):
/usr/bin/rootfs-expand
```

以上操作都没有报错后，就可以使用树莓配的CentOS系统。

### todo

- [ ] Docker安装
- [ ] Kubernetes安装
- [ ] Drone安装
- [ ] GIPO编程
- [ ] ....