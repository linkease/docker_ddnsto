#!/bin/sh

set -eu

PLATFORM=${1:-}
DIST_DIR=${2:-/dist}
DEST_BIN=${DEST_BIN:-/usr/bin/ddnsto}

if [ -z "$PLATFORM" ]; then
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64|amd64)
            DDNSTO_FILE="x86_64"
            ;;
        aarch64|arm64)
            DDNSTO_FILE="aarch64"
            ;;
        armv6l|armv7l|arm)
            DDNSTO_FILE="arm"
            ;;
        mipsel|mipsle)
            DDNSTO_FILE="mipsel"
            ;;
        *)
            DDNSTO_FILE=""
            ;;
    esac
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
        linux/mipsle|linux/mipsel)
            DDNSTO_FILE="mipsel"
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

[ -n "$DDNSTO_FILE" ] || { echo "Error: Not supported OS Architecture" >&2; exit 1; }
[ -f "$DIST_DIR/ddnsto.$DDNSTO_FILE" ] || { echo "Error: Missing binary: $DIST_DIR/ddnsto.$DDNSTO_FILE" >&2; exit 1; }

install -m 0755 "$DIST_DIR/ddnsto.$DDNSTO_FILE" "$DEST_BIN"
echo "Installed $DIST_DIR/ddnsto.$DDNSTO_FILE -> $DEST_BIN"
