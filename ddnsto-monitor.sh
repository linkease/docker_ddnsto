#!/bin/sh

while true ; do
  if ! pidof "ddnsto" > /dev/null ; then
    echo "ddnsto try running"
    /sbin/ddnsto -u ${TOKEN} -
  fi
  sleep 20
done

