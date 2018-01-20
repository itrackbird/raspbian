### 概述

以下记录树莓派使用root用户登录ssh。

### 配置步骤

当开始通过pi用户登录到系统中，首先修改root密码`sudo passwd root`

```sh
pi@raspberrypi:~ $ sudo passwd root
Enter new UNIX password:
Retype new UNIX password:
passwd: password updated successfully
```

之后通过修改sshd_config配置文件来允许root登录系统，不然会出现如下报错

```she
pi@raspberrypi:~ $ ssh root@192.168.137.27
The authenticity of host '192.168.137.27 (192.168.137.27)' can't be established.
ECDSA key fingerprint is SHA256:ysUZ13+j+dFfUyp08/mKDJXdGsAssnsEF1CpEnGaS+A.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '192.168.137.27' (ECDSA) to the list of known hosts.
root@192.168.137.27's password:
Permission denied, please try again.
```

配置文件是/etc/ssh目录中，找到`#PermitRootLogin prohibit-password`,修改成`PermitRootLogin yes`，之后重启ssh服务来加载修改的配置`/etc/init.d/ssh restart`

```sh
root@raspberrypi:/etc/ssh# /etc/init.d/ssh restart
[ ok ] Restarting ssh (via systemctl): ssh.service.
```

之后通过root登录系统

```she
pi@raspberrypi:~ $ ssh root@192.168.137.27
root@192.168.137.27's password:
Linux raspberrypi 4.9.41-v7+ #1023 SMP Tue Aug 8 16:00:15 BST 2017 armv7l

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.

SSH is enabled and the default password for the 'pi' user has not been changed.
This is a security risk - please login as the 'pi' user and type 'passwd' to set a new password.

root@raspberrypi:~# 
```

