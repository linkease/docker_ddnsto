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

DEVICE_NAME: 首次启动使用的稳定设备名，同账号不同设备应使用不同名称。身份文件创建后，该变量只改变显示名称；无身份文件时，必须保留最初的名称（包括大小写、空格）才能重新得到相同 ID。

DEVICE_IDX: 可选，范围 `0 - 99`，默认 `0`；只参与首次身份生成。身份文件存在时，修改编号不会改变设备 ID。不要通过反复删除身份文件或修改编号生成设备。

/your/config-path/ddnsto-config 是宿主机上的持久化目录，挂载到 `/ddnsto-config`。客户端自动创建 `identity.json` 和锁文件；每个容器必须使用自己的目录，不要共享或复制身份状态。

/your/support-path 建议挂载为日志与诊断包目录，方便用户直接打包反馈

```
docker run -d \
    --name=<container name> \
    -e TOKEN=<填入你的token> \
    -e DEVICE_NAME=<给这个容器起一个设备名> \
    -e DEVICE_IDX=0 \
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

## 设备身份与升级恢复

本实现需要包含 `--identity-file` 的新客户端二进制；已经发布的 4.2.8 不具备此能力。
构建脚本会检查该参数，不接受旧二进制。`version` 和发布归档应在新客户端正式发布后一起更新，不覆盖原 4.2.8 归档。

- Docker 启动时固定使用 `--identity-file /ddnsto-config/identity.json`；显示 ID 和实际运行使用相同路径。
- 文件保存格式版本、`name-index-v1` 生成规则、首次名称/编号以及计算结果。不保存 Token，不提供任意指定设备 ID 的环境变量或 `-M` 参数。
- 已有文件优先，后续名称/编号变化不覆盖身份；文件内容与保存的生成输入不符、未知格式、读取/写入失败时退出，不静默换号。
- 无文件时，使用与 4.2.8 相同的名称＋编号确定性算法，保存成功后才连接服务器。不使用容器随机 MAC 或主机名。
- 没有挂载目录时，容器内仍会保存状态，但重建容器会丢失；只有保留最初名称和编号才能重新得到原 ID。修改显示名称后务必保留身份目录。
- `-w`/`-id` 配合 `--identity-file` 会初始化身份文件。需要只读预览生成结果时，不要传 `--identity-file`。

### 已经出现新设备的旧用户

不要删除控制台旧设备，也不要直接把当前错误的新身份固化。先保留升级前配置和镜像信息，再核对生成结果。

历史客户端在指定名称时忽略编号；4.2.8 会把非零编号混入 ID。针对这一兼容差异，在首次启动修复镜像前，用原设备名和编号 `0` 预览：

```sh
docker exec <容器名> sh -c '/usr/bin/ddnsto -u "$TOKEN" -m "$DEVICE_NAME" -x 0 -w'
```

这里没有 `--identity-file`，不会创建身份文件或连接服务器。只有输出 ID 与控制台旧设备完全一致时，才保留原 Token/名称、设置 `DEVICE_IDX=0`，挂载独立目录并启动修复镜像。确认旧设备上线及原域名映射恢复后，再处理多余的新设备。

已经正常使用 4.2.8 新 ID 的用户应保留当前编号，不要统一归零。若预览与旧 ID 不一致，先核对旧版本和旧名称；此流程不保证恢复其他来源的 ID。

如果已经生成了错误的 `identity.json`，修改编号不会覆盖它。应先停止容器、备份并移开整份身份文件，核对上述无文件预览结果后再初始化；不要直接编辑 `router_id`。

### 本地验证

```sh
sh tests/ddnsto-monitor-test.sh
sh tests/ddnsto-support-test.sh
sh tests/install-ddnsto-test.sh
```

防滥用仍需服务端控制。本地状态不是不可篡改的凭证；本次不新增随机重置或指定 ID 的入口，也不代替账号设备上限和新增频率限制。

服务端后续工作：现有注册接口已有账号设备上限，但数量检查使用 `>` 而非 `>=`，且检查在创建事务之外，不能视为严格的并发配额；新增频率限制尚需确定阈值。本次只核查并记录，不修改服务端注册行为。

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
