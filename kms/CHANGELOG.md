# 更新日志

## 2025年5月18日 更新
镜像版本：dothebetter/kms:1113-20250518
1. 镜像版本改为主版本-日期的形式
2. 升级S6_VER版本3.2.1.0
3. 增加UID、GID设置

## 2025年1月19日 更新
镜像版本：dothebetter/kms:20250119
1. 修复访问fonts.googleapis.com缓慢，将字体文件全部本地化

## 2025年1月14日 更新
镜像版本：dothebetter/kms:20250114
1. 增加变量VLKMCSD_OPTS来自定义vlmcsd启动参数

## 2025年1月12日 更新
镜像版本：dothebetter/kms:20250112
1. 使用 https://github.com/Wind4/vlmcsd/releases 搭建，版本1113，默认vlmcsd.kmd数据已更新
2. 系统版本：alpine:3.21
3. 第一次尝试使用s6-overlay v3文件结构制作镜像
