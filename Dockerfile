FROM ubuntu:latest

RUN apt update
RUN apt upgrade -y
RUN apt install -y bash sudo

COPY * /tmp

RUN /tmp/install.sh
RUN rm -rf /tmp/*
