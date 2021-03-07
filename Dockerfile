FROM alpine:latest
RUN apk update
RUN apk add --no-cache --upgrade bash

COPY * /tmp
RUN /tmp/install.sh
RUN rm -rf /tmp/*
