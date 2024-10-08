## 简介：
<p align="center">
<a target="_blank" href="https://github.com/DoTheBetter/docker/tree/master/zerotier-moon"><img alt="Static Badge" src="https://img.shields.io/badge/Github-DoTheBetter%2Fdocker-brightgreen"></a>
<img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/DoTheBetter/docker?label=Repo%20Size">
<img alt="GitHub Actions Workflow Status" src="https://img.shields.io/github/actions/workflow/status/DoTheBetter/docker/DockerBuild_zerotier-moon.yml?label=Actions%20Status">
<br>
<a target="_blank" href="https://github.com/DoTheBetter/docker/pkgs/container/zerotier-moon"><img alt="Static Badge" src="https://img.shields.io/badge/ghcr.io-dothebetter%2Fzerotier--moon-brightgreen"></a>
<a target="_blank" href="https://hub.docker.com/r/dothebetter/zerotier-moon"><img alt="Static Badge" src="https://img.shields.io/badge/docker.io-dothebetter%2Fzerotier--moon-brightgreen"></a>
<img alt="Docker Image Version" src="https://img.shields.io/docker/v/dothebetter/zerotier-moon?label=Image%20Version">
<img alt="Docker Image Size" src="https://img.shields.io/docker/image-size/dothebetter/zerotier-moon?label=Image%20Size">
<img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/dothebetter/zerotier-moon?label=Docker%20Pulls">
</p>
自用zerotier-moon节点镜像，基础系统为alpine，支持amd64;arm64v8;arm32v7系统。

**使用前提条件：**

1.  docker宿主机必须开启TUN/TAP
2.  docker宿主机必须有IPv4或IPv6公网地址

项目地址：https://github.com/DoTheBetter/docker/tree/master/zerotier-moon

### 官网地址

* https://www.zerotier.com
* https://github.com/zerotier/ZeroTierOne

## 相关参数：

#### 环境变量
下面是可用于自定义安装的可用选项的完整列表。  
|变量名|是否必须|默认值|说明|
| :------: | :--------: | :------: | :----: |
|      `TZ`      |   可选   | `Asia/Shanghai` |        设置时区        |
|  `MOON_PORT`   |   可选   |     `9993`      | zerotier-moon使用端口  |
| `IPV4_ADDRESS` | **必须** |      `无`       | moon主机的公网ipv4地址 |
| `IPV6_ADDRESS` |   可选   |      `无`       | moon主机的公网ipv6地址 |

#### 开放的端口

|范围|描述|
| :----: | :----: |
| `9993/udp` | zerotier-moon使用端口默认值。如修改默认端口则为修改后的值 |

#### 数据卷

下面的目录用于配置，并且可以映射为持久存储。  

|目录|描述|
| :----: | :----: |
| `/var/lib/zerotier-one` | zerotier-one配置文件夹 |

## 部署方法：

> 本镜像在docker hub及ghcr.io同步推送，docker hub不能使用时可使用ghcr.io

### Docker Run
  ```bash
  docker run -d \
  	--name zerotier-moon \
  	--restart always \
  	--cap-add NET_ADMIN \
  	--cap-add SYS_ADMIN \
  	--device /dev/net/tun \
  	-e IPV4_ADDRESS=1.2.3.4 \ #moon主机的公网ipv4地址
  	-p 9993:9993/udp \
  	-v /docker/zerotier-moon:/var/lib/zerotier-one \
  	dothebetter/zerotier-moon:latest #ghcr.io/dothebetter/zerotier-moon:latest
  ```
### docker-compose.yml
```yml
version: '3'
services:
  zerotier-moon:
    image: dothebetter/zerotier-moon:latest #ghcr.io/dothebetter/zerotier-moon:latest
    container_name: zerotier-moon
    restart: always
    cap_add:
      - NET_ADMIN
      - SYS_ADMIN
    devices:
      - /dev/net/tun
    environment:
      - IPV4_ADDRESS=1.2.3.4 #moon主机的公网ipv4地址
    ports:
      - "9993:9993/udp"
    volumes:
      - /docker/zerotier-moon:/var/lib/zerotier-one
```

## 更新日志：
详见 **[CHANGELOG.md](./CHANGELOG.md)**