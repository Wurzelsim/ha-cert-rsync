FROM alpine:3.19

RUN apk add --no-cache \
    bash \
    openssh \
    rsync \
    ca-certificates \
    curl \
    jq

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD [ "/run.sh" ]
