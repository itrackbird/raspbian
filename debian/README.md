### 概述

以下是树莓派3B型号安装官方stretch的过程，包括docker的安装和使用。

### 安装步骤

安装步骤同[CentOS](https://github.com/itrackbird/raspbian/tree/master/centOS)安装过程类似，首先下载ISO镜像，格式化TF卡，烧录镜像。

> **镜像地址见[官方地址](http://downloads.raspberrypi.org/raspbian/images)，选择stretch版本，以下操作都是在stretch版本上进行**
>
> **需要注意的是由于debian系统没有自动设置ssh，在烧录镜像后的根目录下需要创建一个文件名为ssh的空白文件，没有任何后缀**

### 登录系统

当安装debianOS后，通过网线连接树梅派网卡，获取到IP后，通过ssh工具连接到系统，用户名密码默认为**pi**/**raspberry**。

> **如何获取树莓派系统IP参考[CentOS安装过程](https://github.com/itrackbird/raspbian/tree/master/centOS)**

### docker安装

安装主要有两步，第一步是给apt换源，第二步是apt安装。

#### 换源

修改sources.list文件内容为国内镜像源地址，如下

```
root@raspberrypi:/etc/apt# cat sources.list
deb http://mirrors.ustc.edu.cn/raspbian/raspbian/ stretch main non-free contrib
deb-src http://mirrors.ustc.edu.cn/raspbian/raspbian/ stretch main non-free contrib
```

然后添加阿里arm的docker源，如下

```she
root@raspberrypi:/etc/apt/sources.list.d# pwd
/etc/apt/sources.list.d
root@raspberrypi:/etc/apt/sources.list.d# cat docker.list
deb [arch=armhf] https://mirrors.aliyun.com/docker-ce/linux/raspbian/ stretch edge
```

> **更换软件源后执行`apt-get update`**

#### 安装

执行下面，等待结束即可。

```she
root@raspberrypi:~# apt-get install docker-ce
```

安装完成后，执行`docker version`如下显示

```she
root@raspberrypi:~# docker version
Client:
 Version:       17.12.0-ce
 API version:   1.35
 Go version:    go1.9.2
 Git commit:    c97c6d6
 Built: Wed Dec 27 20:21:15 2017
 OS/Arch:       linux/arm

Server:
 Engine:
  Version:      17.12.0-ce
  API version:  1.35 (minimum version 1.12)
  Go version:   go1.9.2
  Git commit:   c97c6d6
  Built:        Wed Dec 27 20:17:21 2017
  OS/Arch:      linux/arm
  Experimental: true
```

