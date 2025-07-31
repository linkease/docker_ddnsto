#!/bin/sh

if [ -z "${TOKEN}" ]; then
  echo "the token is empty, get token from https://www.ddnsto.com/ "
  exit 2
fi

if [ -z "${DEVICE_NAME}" ]; then
  echo "the device name is empty, please set DEVICE_NAME"
  exit 2
fi


echo "ddnsto version device_id is:"
/usr/bin/ddnsto -u ${TOKEN} -m ${DEVICE_NAME} -w

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
while true ; do
  if ! pidof "ddnsto" > /dev/null ; then
    echo "ddnsto try running"
    /usr/bin/ddnsto -u ${TOKEN} -m ${DEVICE_NAME}
    
    RET=$?
    echo "EXIT CODE: ${RET}"
    
    if [ "${RET}" == "100" ]; then
      echo "token error, please set a correct token from https://www.ddnsto.com/ "
      exit 100
    fi
  fi
  sleep 20
done