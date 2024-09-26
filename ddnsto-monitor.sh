#!/bin/sh

if [ -z "${TOKEN}" ]; then
  echo "the token is empty, get token from https://www.ddnsto.com/ "
  exit 2
fi

ln -s /ddnsto-config/.ddnsto_boot.cfg /usr/bin/.ddnsto_boot.cfg || true

echo "ddnsto version device_id is is:"
/usr/bin/ddnsto -u ${TOKEN} -w

while true ; do
  if ! pidof "ddnsto" > /dev/null ; then
    echo "ddnsto try running"
    /usr/bin/ddnsto -u ${TOKEN} -x ${DEVICE_IDX} 
    RET=$?
    echo "EXIT CODE: ${RET}" 
    if [ "${RET}" == "100" ]; then
      echo "token error, please set a correct token from https://www.ddnsto.com/ "
      exit 100
    fi
  fi
  sleep 20
done

