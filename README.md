# docker_ddnsto
docker for ddnsto

## build test

docker build -t linkease/ddnsto .

## Usage 

TOKEN: 你从官网拿到的 token

DEVICE_IDX: 默认0，如果设备ID重复则为1-100之间

```
docker run -d \
    --name=<container name> \
    -e TOKEN=<填入你的token> \
    -e DEVICE_IDX=<默认0，如果设备ID重复则为1-100之间> \
    -v /etc/localtime:/etc/localtime:ro \
    -v xxx/ddnsto-config:/ddnsto-config \
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

