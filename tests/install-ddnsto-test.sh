#!/bin/sh
set -eu
REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT INT TERM
mkdir -p "$TMP_DIR/dist"
cat >"$TMP_DIR/dist/ddnsto.x86_64" <<'EOF'
#!/bin/sh
echo 'Usage: ddnsto -u token -m name'
EOF
chmod +x "$TMP_DIR/dist/ddnsto.x86_64"
if DEST_BIN="$TMP_DIR/ddnsto" sh "$REPO_DIR/install-ddnsto.sh" linux/amd64 "$TMP_DIR/dist"; then
  echo "unsupported binary accepted" >&2
  exit 1
fi
[ ! -e "$TMP_DIR/ddnsto" ]
cat >"$TMP_DIR/dist/ddnsto.x86_64" <<'EOF'
#!/bin/sh
echo '  -identity-file string'
EOF
DEST_BIN="$TMP_DIR/ddnsto" sh "$REPO_DIR/install-ddnsto.sh" linux/amd64 "$TMP_DIR/dist"
[ -x "$TMP_DIR/ddnsto" ]
