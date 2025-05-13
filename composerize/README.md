## 简介：

<p align="center">
<a target="_blank" href="https://github.com/DoTheBetter/docker/tree/master/composerize"><img alt="Static Badge" src="https://img.shields.io/badge/Github-DoTheBetter%2Fdocker-brightgreen"></a>
<img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/DoTheBetter/docker?label=GitHub%20repo%20size">
<img alt="GitHub Actions Workflow Status" src="https://img.shields.io/github/actions/workflow/status/DoTheBetter/docker/DockerBuild_composerize.yml?label=GitHub%20Actions%20Workflow%20Status">
<br>
<a target="_blank" href="https://github.com/DoTheBetter/docker/pkgs/container/composerize"><img alt="Static Badge" src="https://img.shields.io/badge/ghcr.io-dothebetter%2Fcomposerize-brightgreen"></a>
<a target="_blank" href="https://hub.docker.com/r/dothebetter/composerize"><img alt="Static Badge" src="https://img.shields.io/badge/docker.io-dothebetter%2Fcomposerize-brightgreen"></a>
<img alt="Docker Image Version" src="https://img.shields.io/docker/v/dothebetter/composerize?label=Image%20Version">
<img alt="Docker Image Size" src="https://img.shields.io/docker/image-size/dothebetter/composerize?label=Image%20Size">
<img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/dothebetter/composerize?label=Docker%20Pulls">
</p>
自用的Docker run命令行与Docker Compose互转工具，基于Alpine，支持多种架构，包括amd64、arm64v8和arm32v7。

- composerize将 Docker run 命令转换为 Docker Compose 配置文件的工具，访问地址：http://localhost:8080
- decomposerize将 Docker Compose 配置反向转换为 Docker run 命令的工具，访问地址：http://localhost:8080/decomposerize
- composeverter支持 Docker Compose v1/v2/v3 格式互转，访问地址：http://localhost:8080/composeverter

项目地址：https://github.com/DoTheBetter/docker/tree/master/composerize

#### 官网地址

- https://github.com/composerize/composerize
- https://github.com/composerize/decomposerize
- https://github.com/outilslibre/composeverter

## 相关参数：

#### 环境变量

下面是可用于自定义安装的可用选项的完整列表。  
|变量名|是否必须|默认值|说明|
| :------: | :--------: | :------: | :----: |
|`TZ`|可选|`Asia/Shanghai`|设置时区|

#### 开放的端口

|  范围  |     描述     |
| :----: | :----------: |
| `8080` | web 服务端口 |

#### 数据卷

下面的目录用于配置，并且可以映射为持久存储。

| 文件或目录 | 描述 |
| :--------: | :--: |
|     -      |  -   |

## 部署方法：

> 本镜像在 docker hub，ghcr.io 及 aliyuncs同步推送，docker hub 不能使用时可使用其他仓库

#### Docker Run

```bash
docker run -d \
    --name composerize \
    --restart always \
    -e TZ=Asia/Shanghai \
    -p 8080:8080 \
    dothebetter/composerize:latest
    #ghcr.io/dothebetter/composerize:latest
    #registry.cn-hangzhou.aliyuncs.com/dothebetter/composerize:latest
```

#### docker-compose.yml

```yaml
services:
    composerize:
        image: dothebetter/composerize:latest
        #ghcr.io/dothebetter/composerize:latest
        #registry.cn-hangzhou.aliyuncs.com/dothebetter/composerize:latest
        container_name: composerize
        restart: always
        environment:
            - TZ=Asia/Shanghai
        ports:
            - 8080:8080
```

## 更新日志：

详见 **[CHANGELOG.md](./CHANGELOG.md)**
