# docker_ddnsto

DDNSTO 帮助你快速外网穿透访问你的局域网设备，无需公网 IP

## build test

docker build -t linkease/ddnsto .

## Usage 

TOKEN: 你从 [官网](https://www.ddnsto.com) 拿到的 token

DEVICE_IDX: 默认 0，如果设备 ID 重复则为 1-100 之间，Docker 有时候生成一模一样的设备 ID，导致无法连接服务器

/your/config-path/ddnsto-config 是你的配置文件，保证重启之后，设备 ID 不变。每个 Docker 都应该设置不同的配置文件路径

```
docker run -d \
    --name=<container name> \
    -e TOKEN=<填入你的token> \
    -e DEVICE_IDX=<默认0，如果设备ID重复则为1-100之间> \
    -v /etc/localtime:/etc/localtime:ro \
    -v /your/config-path/ddnsto-config:/ddnsto-config \
    -e PUID=<uid for user> \
    -e PGID=<gid for user> \
    linkease/ddnsto
```

比如我实际运行的例子：
```
docker run -d \
    --name=ddnstotest \
    -e TOKEN=xxxxxxxx-xxxx-xx28-bdf4-246e98afxxxx \
    -e DEVICE_IDX=0 \
    -v /etc/localtime:/etc/localtime:ro \
    -v /projects/test/ddnsto-config:/ddnsto-config \
    linkease/ddnsto
```

## 镜像地址

https://hub.docker.com/r/linkease/ddnsto/

