#!/bin/sh

PLATFORM=$1
if [ -z "$PLATFORM" ]; then
    DDNSTO_FILE="x64"
else
    case "$PLATFORM" in
        linux/386)
            DDNSTO_FILE=""
            ;;
        linux/amd64)
            DDNSTO_FILE="x64"
            ;;
        linux/arm/v6)
            DDNSTO_FILE="arm"
            ;;
        linux/arm/v7)
            DDNSTO_FILE="arm"
            ;;
        linux/arm64|linux/arm64/v8)
            DDNSTO_FILE="aarch64"
            ;;
        linux/ppc64le)
            DDNSTO_FILE=""
            ;;
        linux/s390x)
            DDNSTO_FILE=""
            ;;
        *)
            DDNSTO_FILE=""
            ;;
    esac
fi
[ -z "${DDNSTO_FILE}" ] && echo "Error: Not supported OS Architecture" && exit 1

echo "Downloading binary file: ${DDNSTO_FILE}"
wget -O /usr/bin/linkease https://firmware.koolshare.cn/binary/ddnsto/${DDNSTO_FILE}/ddnsto > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: Failed to download binary file: ${DDNSTO_FILE}" && exit 1
fi
echo "Download binary file: ${DDNSTO_FILE} completed"

chmod +x /usr/bin/ddnsto

