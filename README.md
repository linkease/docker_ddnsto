# docker_ddnsto

DDNSTO 帮助你快速外网穿透访问你的局域网设备，无需公网 IP

## build test

docker build -t linkease/ddnsto .

## 构建说明

- `Dockerfile.architecture` 是当前正式使用的多架构构建入口。
- `Dockerfile` 仅保留用于本地测试。
- `version` 文件是当前 docker 发布流程的本地版本来源，不依赖 `docker_ddnsto/` 目录外的文件。
- `pre-ddnsto-dl.sh` 会在本地预下载新的 `ddnsto-binary-<version>.tar.gz` 发布包，并展开到 `dist/`。
- `install-ddnsto.sh` 是当前正式使用的安装脚本，会从本地 `dist/` 目录选择目标架构二进制安装到镜像内。
- 历史备份脚本已移到 `legacy/` 目录：`legacy/legacy-pre-download.sh`、`legacy/legacy-ddnsto-install.sh`；当前默认构建链路不再使用。

## Usage 

TOKEN: 你从 [官网](https://www.ddnsto.com) 拿到的 token

DEVICE_NAME: 建议给每个容器一个稳定且可区分的设备名

DEVICE_IDX: 可选，传给 `ddnsto -x <int>`，范围 `0 - 99`，默认留空时由客户端按默认值 `0` 处理；当你需要在重复设备 ID 场景下人为扰动设备标识时再设置。

/your/config-path/ddnsto-config 是你的配置文件，保证重启之后，设备 ID 不变。每个 Docker 都应该设置不同的配置文件路径

/your/support-path 建议挂载为日志与诊断包目录，方便用户直接打包反馈

```
docker run -d \
    --name=<container name> \
    -e TOKEN=<填入你的token> \
    -e DEVICE_NAME=<给这个容器起一个设备名> \
    -e DEVICE_IDX=<可选，0-99，默认留空> \
    -v /etc/localtime:/etc/localtime:ro \
    -v /your/config-path/ddnsto-config:/ddnsto-config \
    -v /your/support-path:/ddnsto-support \
    -e PUID=<uid for user> \
    -e PGID=<gid for user> \
    linkease/ddnsto
```

比如我实际运行的例子：
```
docker run -d \
    --name=ddnstotest \
    -e TOKEN=xxxxxxxx-xxxx-xx28-bdf4-246e98afxxxx \
    -e DEVICE_NAME=nas-a \
    -e DEVICE_IDX=7 \
    -v /etc/localtime:/etc/localtime:ro \
    -v /projects/test/ddnsto-config:/ddnsto-config \
    -v /projects/test/ddnsto-support:/ddnsto-support \
    linkease/ddnsto
```

## 用户反馈问题时导出日志

镜像内置了一个一键支持脚本：`ddnsto-support.sh`

- 手工导出诊断包：

```
docker exec <container name> ddnsto-support.sh bundle user-request
```

- 导出的最新诊断包固定在：

```
/ddnsto-support/latest/ddnsto-support.zip
```

- 如果宿主机已挂载 `-v /your/support-path:/ddnsto-support`，用户可以直接把宿主机里的 zip 文件发给我们。

- 容器也会自动周期性刷新诊断包，并在 `ddnsto` 进程异常退出后自动补抓一份快照。

可选环境变量：

- `DDNSTO_SUPPORT_DIR`：诊断包输出目录，默认 `/ddnsto-support`
- `DDNSTO_AUTO_SUPPORT`：是否开启自动诊断，默认 `1`
- `DDNSTO_AUTO_SUPPORT_INTERVAL`：自动导出间隔秒数，默认 `21600`
- `DDNSTO_SUPPORT_KEEP`：保留历史诊断包数量，默认 `5`

## 镜像地址

https://hub.docker.com/r/linkease/ddnsto/
