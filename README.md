# docker_ddnsto
docker for ddnsto

## build test

docker build -t linkease/ddnsto .

## Usage 

```
docker run -d \
    --name=<container name> \
    -e TOKEN=<填入你的token>
    -e DEVICE_IDX=<默认0，如果设备ID复制则为1-100之间>
    -v /etc/localtime:/etc/localtime:ro \
    -e PUID=<uid for user> \
    -e PGID=<gid for user> \
    linkease/ddnsto
```
