#!/bin/sh

# 定义需要下载的架构列表
ARCH_LIST="x86_64 arm aarch64"
BIN_DIR="./bin"

# 创建 bin 目录（如果不存在）
mkdir -p "${BIN_DIR}"

# 遍历架构列表并下载对应的二进制文件
for ARCH in $ARCH_LIST; do
    DOWNLOAD_URL="https://fw0.koolcenter.com/binary/ddnsto/linux/ddnstox/ddnstox.${ARCH}"
    OUTPUT_FILE="${BIN_DIR}/ddnstox.${ARCH}"

    echo "Downloading binary file for architecture: ${ARCH} from: ${DOWNLOAD_URL}"
    wget --no-check-certificate -O "${OUTPUT_FILE}" "${DOWNLOAD_URL}" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download binary file for architecture: ${ARCH} from: ${DOWNLOAD_URL}"
        continue
    fi
    echo "Download binary file: ${ARCH} completed"

    chmod +x "${OUTPUT_FILE}"
done

echo "All downloads completed."