#!/bin/sh

set -eu

if [ -z "${TOKEN:-}" ]; then
  echo "the token is empty, get token from https://www.ddnsto.com/ "
  exit 2
fi

if [ -z "${DEVICE_NAME:-}" ]; then
  echo "the device name is empty, please set DEVICE_NAME"
  exit 2
fi

validate_device_idx() {
  if [ -z "${DEVICE_IDX:-}" ]; then
    return 0
  fi

  case "${DEVICE_IDX}" in
    *[!0-9]*)
      echo "DEVICE_IDX must be an integer between 0 and 99"
      exit 2
      ;;
  esac

  if [ "${DEVICE_IDX}" -lt 0 ] || [ "${DEVICE_IDX}" -gt 99 ]; then
    echo "DEVICE_IDX must be an integer between 0 and 99"
    exit 2
  fi
}

validate_device_idx

# Identity is owned by the client and persisted before any server connection.
# Keep the path fixed so rebuilding the container reuses the mounted state.
run_ddnsto() {
  if [ -n "${DEVICE_IDX:-}" ]; then
    /usr/bin/ddnsto -u "${TOKEN}" -m "${DEVICE_NAME}" -x "${DEVICE_IDX}" --identity-file /ddnsto-config/identity.json "$@"
  else
    /usr/bin/ddnsto -u "${TOKEN}" -m "${DEVICE_NAME}" --identity-file /ddnsto-config/identity.json "$@"
  fi
}

echo "ddnsto version device_id is:"
run_ddnsto -w

print_support_help() {
  echo "support bundle path: ${DDNSTO_SUPPORT_DIR:-/ddnsto-support}/latest/ddnsto-support.zip"
  echo "if the device goes offline, run:"
  echo "  docker exec <container_name> ddnsto-support.sh bundle user-request"
}

start_auto_bundle_loop() {
  if [ "${DDNSTO_AUTO_SUPPORT:-1}" != "1" ]; then
    return 0
  fi

  interval="${DDNSTO_AUTO_SUPPORT_INTERVAL:-21600}"
  (
    while true; do
      sleep "$interval"
      /usr/bin/ddnsto-support.sh auto periodic >/dev/null 2>&1 || true
    done
  ) &
}

# 启动日志转发进程（后台运行）
tail_logs() {
  # 等待日志文件创建 
  if [ ! -f /tmp/logs/ddnstoshell.log ]; then
    echo "Log file /tmp/logs/ddnstoshell.log does not exist, creating it."
    mkdir -p /tmp/logs
    touch /tmp/logs/ddnstoshell.log
  fi
  # 持续转发日志到stdout
  tail -f /tmp/logs/ddnstoshell.log &
  TAIL_PID=$!
}
tail_logs
print_support_help
start_auto_bundle_loop
while true ; do
  if ! pidof "ddnsto" > /dev/null ; then
    echo "ddnsto try running"
    RET=0
    if [ -n "${SUPPLIER_CODE:-}" ]; then
      run_ddnsto --supplierCode="${SUPPLIER_CODE}" || RET=$?
    else
      run_ddnsto || RET=$?
    fi
    echo "EXIT CODE: ${RET}"
    /usr/bin/ddnsto-support.sh auto process-exit >/dev/null 2>&1 || true
    
    if [ "${RET}" = "205" ] || [ "${RET}" = "2" ]; then
      echo "identity/configuration error; preserve /ddnsto-config and fix the reported error"
      exit "${RET}"
    fi
    if [ "${RET}" = "100" ]; then
      echo "token error, please set a correct token from https://www.ddnsto.com/ "
      exit 100
    fi
  fi
  sleep 20
done
