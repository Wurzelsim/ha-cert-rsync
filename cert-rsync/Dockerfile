ARG BUILD_FROM
FROM $BUILD_FROM

RUN apk add --no-cache \
    openssh \
    rsync \
    ca-certificates \
    curl \
    jq

# Copy data
COPY rootfs /
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD [ "/run.sh" ]


