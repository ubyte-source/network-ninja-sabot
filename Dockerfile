FROM nodered/node-red:latest

USER root

RUN apk add sudo nmap sqlite && \
    echo 'node-red ALL = NOPASSWD: /usr/bin/nmap' >> /etc/sudoers

USER node-red