# Dockerfile for LinkEase based alpine
# Copyright (C) 2020 - 2020 Janson <janson@linkease.com>
# Reference URL:
# https://www.ddnsto.com/

FROM alpine:latest
LABEL maintainer="Janson <janson@linkease.com>"

COPY ddnsto-dl.sh /root/ddnsto-dl.sh
RUN set -ex \
	&& chmod +x /root/ddnsto-dl.sh \
	&& /root/ddnsto-dl.sh

VOLUME /ddnsto-config

ENV TZ=Asia/Shanghai

ENV DDNSTO_CONFIG=/ddnsto-config

CMD [ "/usr/bin/ddnsto"]
