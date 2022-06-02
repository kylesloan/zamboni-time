# not sure why but 22.04 blows up currently on build
FROM ubuntu:20.04
RUN echo 20220531-856
RUN apt-get update && \
    apt-get install -y \
    curl \
    jq \
    less \
    nginx \
    shellcheck \
    vim
RUN curl -L https://github.com/aelsabbahy/goss/releases/latest/download/goss-linux-amd64 -o /usr/local/bin/goss && \
    chmod +rx /usr/local/bin/goss
WORKDIR /mnt
COPY Dockerfile /
