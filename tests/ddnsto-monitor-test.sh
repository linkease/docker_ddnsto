#!/bin/sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
TMP_DIR=$(mktemp -d)

cleanup() {
    rm -rf "$TMP_DIR"
}

trap cleanup EXIT INT TERM

mkdir -p "$TMP_DIR/bin" "$TMP_DIR/logs" "$TMP_DIR/support"

sed \
    -e "s|/usr/bin/ddnsto|ddnsto|g" \
    -e "s|/usr/bin/ddnsto-support.sh|ddnsto-support.sh|g" \
    "$REPO_DIR/ddnsto-monitor.sh" >"$TMP_DIR/ddnsto-monitor.sh"
chmod +x "$TMP_DIR/ddnsto-monitor.sh"

cat >"$TMP_DIR/bin/ddnsto" <<'EOF'
#!/bin/sh
set -eu

printf '%s\n' "$*" >>"$DDNSTO_ARGS_LOG"

for arg in "$@"; do
    if [ "$arg" = "-w" ]; then
        exit 0
    fi
done

exit 100
EOF

cat >"$TMP_DIR/bin/pidof" <<'EOF'
#!/bin/sh
exit 1
EOF

cat >"$TMP_DIR/bin/tail" <<'EOF'
#!/bin/sh
exit 0
EOF

cat >"$TMP_DIR/bin/sleep" <<'EOF'
#!/bin/sh
exit 0
EOF

cat >"$TMP_DIR/bin/ddnsto-support.sh" <<'EOF'
#!/bin/sh
exit 0
EOF

chmod +x "$TMP_DIR/bin/ddnsto" "$TMP_DIR/bin/pidof" "$TMP_DIR/bin/tail" "$TMP_DIR/bin/sleep" "$TMP_DIR/bin/ddnsto-support.sh"

ARGS_LOG="$TMP_DIR/args.log"
STATUS=0
if PATH="$TMP_DIR/bin:$PATH" \
    DDNSTO_ARGS_LOG="$ARGS_LOG" \
    TOKEN="test-token" \
    DEVICE_NAME="device-a" \
    DEVICE_IDX="7" \
    DDNSTO_SUPPORT_DIR="$TMP_DIR/support" \
    DDNSTO_AUTO_SUPPORT="0" \
    sh "$TMP_DIR/ddnsto-monitor.sh"
then
    STATUS=0
else
    STATUS=$?
fi

[ "$STATUS" = "100" ]
grep -q -- "-u test-token -m device-a -x 7 -w" "$ARGS_LOG"
grep -q -- "-u test-token -m device-a -x 7" "$ARGS_LOG"
