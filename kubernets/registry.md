### 概述

以下主要是记录在树莓派上搭建个人的registry镜像仓库，在此系统中同时进行源码编译产生镜像，加速构建过程。

### 安装

在树莓派中无法通过pull官方镜像registry来安装，所以需要通过[registry源码](https://github.com/docker/distribution)来安装。首先下载项目源码

```she
root@raspberrypi:/opt# git clone https://github.com/docker/distribution
```

等待结束，后在`distribution`目录中会有官方的Dockerfile文件，修改编译系统为`arm`就可以构建出树莓派的registry

```she
root@raspberrypi:/opt/distribution# cat Dockerfile
FROM golang:alpine

RUN echo "http://mirrors.aliyun.com/alpine/v3.6/main/" > /etc/apk/repositories

ENV DISTRIBUTION_DIR /go/src/github.com/docker/distribution
ENV DOCKER_BUILDTAGS include_oss include_gcs

ARG GOOS=linux
ARG GOARCH=arm

RUN set -ex \
    && apk add --no-cache make git libc-dev gcc make

WORKDIR $DISTRIBUTION_DIR
COPY . $DISTRIBUTION_DIR
COPY cmd/registry/config-dev.yml /etc/docker/registry/config.yml

RUN make PREFIX=/go clean binaries

VOLUME ["/var/lib/registry"]
EXPOSE 5000
ENTRYPOINT ["registry"]
CMD ["serve", "/etc/docker/registry/config.yml"]

```

> **修改alpine软件源为阿里云，加速下载过程，修改GOARCH为arm系统**

之后输入`docker build -t registry .`

```shell
root@raspberrypi:/opt/distribution# docker build -t registry .
```

```she
root@raspberrypi:/opt/distribution# docker images | grep registry
registry                        latest              8473b6d53596        2 hours ago         318MB
```

之后，我们就可以使用此镜像来安装私有镜像仓库。

```shell
root@raspberrypi:/opt/distribution# docker run -d --name registry -p 5000:5000 registry
root@raspberrypi:/opt/distribution# docker ps  | grep registry
c4fb2fa82678        registry            "registry serve /etc…"   2 hours ago         Up 2 hours          0.0.0.0:5000->5000/tcp             registry
```

最后，我们通过`docker tag alpine  192.168.137.24:5000/test/alpine`来推送此镜像进行测试。

```shell
root@raspberrypi:/home/pi# docker tag nginx 192.168.137.24:5000/test/pzm
root@raspberrypi:/home/pi# docker push 192.168.137.24:5000/test/pzm
The push refers to repository [192.168.137.24:5000/test/pzm]
Get https://192.168.137.24:5000/v2/: http: server gave HTTP response to HTTPS client
```

当出现这个报错，需要我们在docker的配置文件daemon.json中添加`{ "insecure-registries":["192.168.1.100:5000"] }`，如下所示

```shell
root@raspberrypi:/etc/docker# pwd
/etc/docker
root@raspberrypi:/etc/docker# cat daemon.json
{
  "insecure-registries": ["192.168.137.24:5000"]
}
```

然后重启docker即可。

```shell
root@raspberrypi:/etc/docker# /etc/init.d/docker stop
root@raspberrypi:/etc/docker# /etc/init.d/docker start
```

以上是在树莓派搭建registry的整个过程。
