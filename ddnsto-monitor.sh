#!/bin/sh

if [ -z "${TOKEN}" ]; then
  echo "the token is empty, get token from https://www.ddnsto.com/ "
  exit 2
fi

while true ; do
  if ! pidof "ddnsto" > /dev/null ; then
    echo "ddnsto try running"
    /sbin/ddnsto -u ${TOKEN} -x ${DEVICE_IDX} -l ${LOG_LEVEL}
    RET=$?
    echo "EXIT CODE: ${RET}" 
    if [ "${RET}" == "100" ]; then
      echo "token error, please set a correct token from https://www.ddnsto.com/ "
      exit 100
    fi
  fi
  sleep 20
done

