### 概述

由于CentOS的树莓派镜像暂时不能支持docker，故下载rancherOS树莓派镜像安装docker，以下是记录rancherOS安装过程。

### 安装步骤

安装步骤同[CentOS](https://github.com/itrackbird/raspbian/tree/master/centOS)安装过程类似，首先下载ISO镜像，格式化TF卡，烧录镜像。

> **镜像下载地址见[rancher官方镜像地址](https://github.com/rancher/os/releases/)**

### 登录系统

当安装rancherOS后，通过网线连接树梅派网卡，获取到IP后，通过ssh工具连接到系统，用户名密码默认为rancher/rancher。

> **如何获取树莓派系统IP参考[CentOS安装过程](https://github.com/itrackbird/raspbian/tree/master/centOS)**

### 使用docker

rancherOS安装完毕后，默认是安装好docker软件。

```she
[rancher@rancher ~]$ docker version
Client:
 Version:      17.03.1-ce
 API version:  1.27
 Go version:   go1.7.5
 Git commit:   c6d412e
 Built:        Sun Jun  4 02:49:46 2017
 OS/Arch:      linux/arm64

Server:
 Version:      17.03.1-ce
 API version:  1.27 (minimum version 1.12)
 Go version:   go1.7.5
 Git commit:   c6d412e
 Built:        Sun Jun  4 02:49:46 2017
 OS/Arch:      linux/arm64
 Experimental: true
```

接下来切换至root权限操作，在切换root前，修改root密码。

```she
[rancher@rancher ~]$ sudo passwd root
Changing password for root
New password:
Retype password:
passwd: password for root changed by root
[rancher@rancher ~]$ su - root
Password:
[root@rancher ~]#
```

之后，在docker中添加阿里云docker加速器，需要在`/etc/docker`目录中添加daemon.json文件，默认是没有的，在文件里加入阿里云提供的加速镜像地址

```sh
[root@rancher docker]# ls
cni                 daemon.json         hooks               key.json            system-docker.json
[root@rancher docker]# vi daemon.json
[root@rancher docker]# cat daemon.json
{
  "registry-mirrors": ["https://xxxxxx.aliyuncs.com"],
  "metrics-addr": "127.0.0.1:9323",
  "experimental": true
}
```

之后重启docker，这里需要注意的使用rancherOS自带的服务重启指令ros。

```shell
[root@rancher docker]# ros service restart docker
```

重启完毕后，输入`docker ps`不报错就表示成功。有可能出现重启失败，再次执行`ros service start docker`后查看是否成功。

> **关于ros指令详情，通过ros -h来获取帮助说明**

### 启动容器

接下来以启动官方的nginx来验证docker使用

```she
[root@rancher docker]# docker pull nginx
Using default tag: latest
latest: Pulling from library/nginx
fcad8cfc11c7: Pull complete
80babc1da4df: Pull complete
d4ab4e5645f5: Pull complete
Digest: sha256:285b49d42c703fdf257d1e2422765c4ba9d3e37768d6ea83d7fe2043dad6e63d
Status: Downloaded newer image for nginx:latest
[root@rancher docker]# docker run -d --name nginx -p 80:80 nginx
dbd072b31a81987a88fceb2a116f8725084d264cb489c83c5330092cc2a35b77
[root@rancher docker]# docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                NAMES
dbd072b31a81        nginx               "nginx -g 'daemon ..."   3 seconds ago       Up 1 second         0.0.0.0:80->80/tcp   nginx
```

在启动nginx容器后，访问宿主机的IP，确认服务是否正常。

```shell
[root@rancher docker]# ifconfig
eth0      Link encap:Ethernet  HWaddr B8:27:EB:B1:81:D4
          inet addr:192.168.137.184  Bcast:192.168.137.255  Mask:255.255.255.0
          inet6 addr: fe80::ba27:ebff:feb1:81d4/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:400452 errors:0 dropped:0 overruns:0 frame:0
          TX packets:159279 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:570680507 (544.2 MiB)  TX bytes:12108594 (11.5 MiB)
```

找到对应的IP之后，再浏览器中直接输入IP，出现nginx的欢迎页面则表示正常。

### 文件扩展

当我们通过`df -h`发现磁盘大小为1个G左右，这时我们需要通过文件扩展命令来加载剩余的磁盘空间，详细操作步骤参考rancherOS[官网介绍](http://rancher.com/docs/os/v1.1/en/running-rancheros/server/raspberry-pi/)，以下是个人操作记录日志

```she
[root@rancher ~]# fdisk /dev/mmcblk0

Welcome to fdisk (util-linux 2.29.2).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help):


Command (m for help): n
Partition type
   p   primary (2 primary, 0 extended, 2 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (3,4, default 3):
First sector (4194304-62333951, default 4194304):
Last sector, +sectors or +size{K,M,G,T,P} (4194304-62333951, default 62333951):

Created a new partition 3 of type 'Linux' and of size 27.7 GiB.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Re-reading the partition table failed.: Device or resource busy

The kernel still uses the old table. The new table will be used at the next reboot or after you run partprobe(8) or kpartx(8).
```

