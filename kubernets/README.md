### 概述

以下记录在树莓派3B的[debian](https://github.com/itrackbird/raspbian/tree/master/debian)系统中安装kubernets系统，采用二进制文件安装整个系统。

### 准备工作

在安装k8s之前，需要对系统环境进行配置

* 关闭swap
* 安装etcd
* 安装flannel

#### 关闭swap

在k8s安装过程中不能存在swap虚拟内存，否则安装报错，参考官方kubernets说明。在系统中关闭swap主要有两种，临时关闭或者永久关闭，参考博文[关闭swap方式](https://www.xtplayer.cn/2017/10/3162)。

在系统中用root用户执行`swapoff -a`来关闭虚拟内存

```she
root@raspberrypi:/home/pi# swapoff -a
root@raspberrypi:/home/pi# free -m
              total        used        free      shared  buff/cache   available
Mem:            927          63         705           6         158         808
Swap:             0           0           0
```

> **树莓派root登录参考[root用户设置](https://github.com/itrackbird/raspbian/tree/master/debian/root.md)**

#### 安装etcd

