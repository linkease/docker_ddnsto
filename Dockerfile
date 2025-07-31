# Dockerfile for DDNSTO based alpine
# Copyright (C) 2020 - 2020 Janson <janson@linkease.com>
# Reference URL:
# https://www.ddnsto.com/

FROM alpine:latest
LABEL maintainer="Janson <janson@linkease.com>"

COPY ddnsto-dl.sh /root/ddnsto-dl.sh
COPY ddnsto-monitor.sh /usr/bin/ddnsto-monitor.sh
#COPY ddnsto /usr/bin/ddnsto
RUN set -ex \
	&& chmod +x /root/ddnsto-dl.sh \
	&& /root/ddnsto-dl.sh

RUN chmod +x /usr/bin/ddnsto-monitor.sh /usr/bin/ddnsto

ENV TZ=Asia/Shanghai
ENV TOKEN=
ENV DEVICE_NAME=
ENV LOG_LEVEL=2

CMD [ "/usr/bin/ddnsto-monitor.sh"]
