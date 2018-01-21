### 概述

这是关于在树莓派上使用ansible进行linux系统批量管理，关于其介绍与使用参考[ansible官网](http://docs.ansible.com/ansible/latest/intro.html)。

### ansible安装

安装方式rpm安装、源码安装以及pip安装，以下介绍使用pip来安装。

因python2默认没有安装pip，所以我们需要先在树莓派系统中安装pip

```she
root@raspberrypi:~# apt-get install python-pip
```

等待安装结束即可，之后更改pip的软件源为阿里云地址，加速下载速度。首先在家目录下先建一个`.pip`目录

```she
root@raspberrypi:~# pwd
/root
root@raspberrypi:~# mkdir .pip
```

然后创建一个pip.conf文件，添加阿里云地址，如下

```shell
root@raspberrypi:~/.pip# cat pip.conf
[global]
trusted-host=mirrors.aliyun.com
index-url=https://mirrors.aliyun.com/pypi/simple/
```

最后，我们就可以使用pip来安装ansible。

```she
root@raspberrypi:/opt# pip install ansible
```

过程出现的报错，安装提示安装对应依赖包即可。

```shell
  Complete output from command python setup.py egg_info:
    Package libffi was not found in the pkg-config search path.
    Perhaps you should add the directory containing `libffi.pc'
    to the PKG_CONFIG_PATH environment variable
    No package 'libffi' found
root@raspberrypi:/opt# apt-get install libffi-dev
```

```shell
  build/temp.linux-armv7l-2.7/_openssl.c:493:30: fatal error: openssl/opensslv.h: No such file or directory
root@raspberrypi:/opt# apt-get install  openssl
root@raspberrypi:/opt# apt-get install libssl-dev
```

