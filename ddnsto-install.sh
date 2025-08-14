#!/bin/sh

PLATFORM=$1
if [ -z "$PLATFORM" ]; then
    DDNSTO_FILE="x86_64"
else
    case "$PLATFORM" in
        linux/386)
            DDNSTO_FILE=""
            ;;
        linux/amd64)
            DDNSTO_FILE="x86_64"
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
DDNSTO_FILE="bin/ddnstox.${DDNSTO_FILE}"
cp -f "${DDNSTO_FILE}" /usr/bin/ddnsto
chmod +x /usr/bin/ddnsto