FROM debian:sid
MAINTAINER Jaseem Abid <jaseemabid@gmail.com>

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Setup base image deps
RUN apt-get update && apt-get install -y \
    openvpn
    # && rm -rf /var/lib/apt/lists/*

COPY ./main /
COPY ./openvpn.conf /etc/openvpn/openvpn.conf

ENTRYPOINT ["/main"]
