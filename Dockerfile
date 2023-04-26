FROM amd64/alpine:3.15

ENV STARTUP_COMMAND_RUN_NODERED="/usr/bin/node /usr/local/lib/node_modules/node-red/red.js --userDir /data | node-red"

ARG TIMEZONE="UTC"

RUN apk update && \
    apk add --no-cache sudo nmap sqlite iputils nodejs tftp-hpa && \
    apk add --no-cache tzdata && \
    rm -rf /var/cache/apk/*

COPY wrapper.sh /

RUN adduser -D -g sabot sabot && \
    mkdir -p /data/tftp && \
    chown -R sabot:sabot /home/sabot /usr/local/lib /data && \
    chmod +x wrapper.sh && \
    cp -r /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo "${TIMEZONE}" > /etc/timezone && \
    echo 'sabot ALL = NOPASSWD: /usr/bin/nmap' >> /etc/sudoers

RUN npm install -g --unsafe-perm node-red

EXPOSE 1880

USER sabot

ENTRYPOINT /wrapper.sh