### 概述

以下记录在树莓派3B的[debian](https://github.com/itrackbird/raspbian/tree/master/debian)系统中安装kubernets系统，采用二进制文件安装整个系统。

### 准备工作

在安装k8s之前，需要对系统环境进行配置

* ssh免密码
* ansible管理


* 关闭swap
* 集群etcd
* 安装flannel

### ssh免密码

在安装k8s过程中是通过root用户操作，所以我们需要设置sshd，参考[root设置](https://github.com/itrackbird/raspbian/blob/master/kubernets/root.md)。在设置完毕后，通过expect脚本来实现免密码登录各个系统，首先安装`expect`

```shell
root@raspberrypi:/etc/apt/sources.list.d# apt-get install expect
```

之后，在各个系统中输入`ssh-keygen`来生成秘钥

```shell
root@raspberrypi:/etc/apt/sources.list.d# ssh-keygen
```

以上操作结束后，我们就准备好了exepct脚本需要的环境，然后从网上找到exepct脚本，如下

```shell
root@raspberrypi:/pzm/script# cat auto_ssh.sh
#!/usr/bin/expect
set timeout 10
set username [lindex $argv 0]
set password [lindex $argv 1]
set hostname [lindex $argv 2]
spawn ssh-copy-id -f -i /root/.ssh/id_rsa.pub $username@$hostname
expect {
            #first connect, no public key in ~/.ssh/known_hosts
            "Are you sure you want to continue connecting (yes/no)?" {
            send "yes\r"
            expect "password:"
                send "$password\r"
            }
            #already has public key in ~/.ssh/known_hosts
            "password:" {
                send "$password\r"
            }
            "Now try logging into the machine" {
                #it has authorized, do nothing!
            }
        }
expect eof
```

之后，编写bash脚本来实现多系统之间免密码登录。

```shell
(env) root@raspberrypi:/pzm/script# cat setup.sh
#!/usr/bin/env bash
ips=`cat host.ip`
passwd="123456"
for ip in $ips
do
        echo "=========$ip==========="
        ./auto_ssh.sh root $passwd $ip
done
```

`setup.sh`实现读取host.ip文件中IP列表，之后调用`auto_ssh.sh`，然后我们执行`setup.sh`脚本即可实现免密码登录。

### ansible安装

Ansible基于Python语言实现，由paramiko和PyYAML两个关键模块构建。Ansible的编排引擎可以出色地完成配置管理，流程控制，资源部署等多方面工作。

ansible安装方式通过pip模块来安装，输入`pip install ansible`等待完成即可，参考[ansible配置](https://github.com/itrackbird/raspbian/tree/master/kubernets/ansible.md)。应用场景主要是讲安装过程中通用配置文件通过批量复制，减少操作步骤。对于k8s在x86_64机器上安装k8s，也支持通过ansible来进行安装，可以参考github上一个开源项目[gjmzj/kubeasz](https://github.com/gjmzj/kubeasz)。

### 关闭swap

在k8s安装过程中不能存在swap虚拟内存，否则安装报错，参考官方kubernets说明。在系统中关闭swap主要有两种，临时关闭或者永久关闭，参考博文[关闭swap方式](https://www.xtplayer.cn/2017/10/3162)。

在系统中用root用户执行`swapoff -a`来关闭虚拟内存

```shell
root@raspberrypi:/home/pi# swapoff -a
root@raspberrypi:/home/pi# free -m
              total        used        free      shared  buff/cache   available
Mem:            927          63         705           6         158         808
Swap:             0           0           0
```

> **树莓派root登录参考[root用户设置](https://github.com/itrackbird/raspbian/blob/master/kubernets/root.md)**

### etcd集群

搭建etcd集群是通过docker容器来搭建的，但是在etcd官方镜像无法直接运行在树莓派上，所以需要在树莓派中通过Dockerfile来构建我们的etcd镜像，之后在每个节点上运行etcd容器。

#### etcd镜像

在树莓派安装etcd需要进行源码编译，首先通过git下载etcd项目

```she
root@raspberrypi:/opt# git clone https://github.com/coreos/etcd.git
```

在etcd目录中会有Dockerfile文件，之后通过在本地`docker build`来制作etcd镜像

```she
root@raspberrypi:/opt/etcd# pwd
/opt/etcd
root@raspberrypi:/opt/etcd# ls Dockerfile
Dockerfile
root@raspberrypi:/opt/etcd# cat Dockerfile
FROM golang
ENV ETCD_UNSUPPORTED_ARCH arm
ADD . /go/src/github.com/coreos/etcd
ADD cmd/vendor /go/src/github.com/coreos/etcd/vendor
RUN go install github.com/coreos/etcd
EXPOSE 2379 2380
ENTRYPOINT ["etcd"]
```

> **其中ENV ETCD_UNSUPPORTED_ARCH arm是需要手动添加的，不添加的话etcd无法启动**

之后在源代码etcd目录中使用`docker build -t pzm .`，等待构建完成，之后我们就可以在树莓派上建立etcd集群。

> **pzm是构建的镜像名称，之后将构建的镜像推送到[镜像仓库](https://github.com/itrackbird/raspbian/tree/master/kubernets/registry.md)**

#### etcd容器

关于使用docker搭建etcd集群，可以参考[官方安装指导](https://coreos.com/etcd/docs/latest/op-guide/container.html#docker)来完成。

首先，我们使用刚才构建好的etcd镜像来运行一个单点集群

```sh
export HostIP=192.168.137.24
```

> **将192.168.137.24修改成自己的ip地址**

```she
docker run -d -e ETCD_UNSUPPORTED_ARCH=arm -p 2380:2380 -p 2379:2379 --name etcd pzm --name etcd0 -advertise-client-urls http://${HostIP}:2379 -listen-client-urls http://0.0.0.0:2379 -initial-advertise-peer-urls http://${HostIP}:2380 -listen-peer-urls http://0.0.0.0:2380 -initial-cluster-token etcd-cluster-1 -initial-cluster etcd0=http://${HostIP}:2380 -initial-cluster-state new
```

之后通过`etcdctl --endpoints=http://${HostIP}:2379 member list`来验证是否正确

```shell
root@raspberrypi:/opt/etcd# ./bin/etcdctl --endpoints=//$HostIP:2379 member list
4379111a2ad8872f: name=etcd0 peerURLs=http://192.168.137.24:2380 clientURLs=http://192.168.137.24:2379 isLeader=true
```

以上我们就构建好我们自己的树莓派etcd镜像。

#### 集群安装



