FROM amd64/alpine:3.18

ENV STARTUP_COMMAND_RUN_TFTP="/usr/bin/sudo /usr/sbin/in.tftpd --ipv4 --foreground --user sabot --address 0.0.0.0:69 --secure /var/tftpboot --blocksize 1380 --port-range 40000:48000 --timeout 2592000"
ENV STARTUP_COMMAND_RUN_NODERED="/usr/bin/node /usr/local/lib/node_modules/node-red/red.js --userDir /data | node-red"

ARG TIMEZONE="UTC"

RUN apk update && \
    apk add --no-cache sudo nmap sqlite iputils nodejs npm tftp-hpa && \
    apk add --no-cache tzdata && \
    rm -rf /var/cache/apk/*

COPY wrapper.sh /

RUN adduser -D -g sabot sabot && \
    chown -R sabot:sabot /home/sabot /usr/local/lib /var/tftpboot && \
    chmod +x wrapper.sh && \
    touch /etc/sudoers.d/nopasswd && \
    cp -r /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo "${TIMEZONE}" > /etc/timezone && \
    echo 'sabot ALL=NOPASSWD: /usr/bin/nmap' >> /etc/sudoers.d/nopasswd && \
    echo 'sabot ALL=NOPASSWD: /usr/sbin/in.tftpd' >> /etc/sudoers.d/nopasswd

RUN npm install -g --unsafe-perm node-red

EXPOSE 1880/tcp 69/udp 40000-48000/udp

USER sabot

ENTRYPOINT /wrapper.sh