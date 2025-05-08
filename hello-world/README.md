## 简介：
<p align="center">
<a target="_blank" href="https://github.com/DoTheBetter/docker/tree/master/hello-world"><img alt="Static Badge" src="https://img.shields.io/badge/Github-DoTheBetter%2Fdocker-brightgreen"></a>
<img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/DoTheBetter/docker?label=GitHub%20repo%20size">
<img alt="GitHub Actions Workflow Status" src="https://img.shields.io/github/actions/workflow/status/DoTheBetter/docker/DockerBuild_hello-world.yml?label=GitHub%20Actions%20Workflow%20Status">
<br>
<a target="_blank" href="https://github.com/DoTheBetter/docker/pkgs/container/hello-world"><img alt="Static Badge" src="https://img.shields.io/badge/ghcr.io-dothebetter%2Fhello--world-brightgreen"></a>
<a target="_blank" href="https://hub.docker.com/r/dothebetter/hello-world"><img alt="Static Badge" src="https://img.shields.io/badge/docker.io-dothebetter%2Fhello--world-brightgreen"></a>
<img alt="Docker Image Version" src="https://img.shields.io/docker/v/dothebetter/hello-world?label=Image%20Version">
<img alt="Docker Image Size" src="https://img.shields.io/docker/image-size/dothebetter/hello-world?label=Image%20Size">
<img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/dothebetter/hello-world?label=Docker%20Pulls">
</p>

​		自用docker.io及ghcr.io连通性测试镜像，支持amd64;arm64v8;arm32v7系统。

​		本镜像使用`golang`语言静态编译的`Hello World`程序，在 `scratch` 镜像中运行,最终镜像只有2MB左右。用于配合自用docker镜像源连通性检测脚本使用，可同时匹配docker.io及ghcr.io。



项目地址：https://github.com/DoTheBetter/docker/tree/master/hello-world


## 使用方法：

> 本镜像在 docker hub，ghcr.io 及 aliyuncs同步推送，docker hub 不能使用时可使用其他仓库
### 拉取并运行镜像
```bash
docker run --rm dothebetter/hello-world:latest
#docker run --rm ghcr.io/dothebetter/hello-world:latest
#docker run --rm registry.cn-hangzhou.aliyuncs.com/dothebetter/hello-world:latest
```

如果一切正常，你应该会看到输出：
```bash
Hello, World!
```
