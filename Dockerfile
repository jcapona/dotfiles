FROM alpine:latest

RUN apk update
RUN apk add --no-cache --upgrade bash sudo

COPY * /tmp

RUN /tmp/install.sh
RUN rm -rf /tmp/*
