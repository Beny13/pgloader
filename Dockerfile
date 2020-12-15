FROM debian:bullseye-slim as builder

  RUN apt-get update \
      && apt-get install -y --no-install-recommends \
        bzip2 \
        ca-certificates \
        curl \
        freetds-dev \
        gawk \
        git \
        libsqlite3-dev \
        libssl1.1 \
        libzip-dev \
        make \
        openssl \
        patch \
        sbcl \
        time \
        unzip \
        wget \
        cl-ironclad \
        cl-babel \
      && rm -rf /var/lib/apt/lists/*

  COPY ./ /opt/src/pgloader

  RUN mkdir -p /opt/src/pgloader/build/bin \
      && cd /opt/src/pgloader \
      && make clones save

FROM debian:stable-slim

  RUN apt-get update \
      && apt-get install -y --no-install-recommends \
        curl \
        freetds-dev \
        gawk \
        libsqlite3-dev \
        libzip-dev \
        make \
        sbcl \
        unzip \
      && rm -rf /var/lib/apt/lists/*

  COPY --from=builder /opt/src/pgloader/build/bin/pgloader /usr/local/bin
  ADD pgloader_schema /root
  ADD pgloader_data /root
  ADD freetds.conf /etc/freetds/freetds.conf

  WORKDIR /root
  CMD bash -c "/usr/local/bin/pgloader --on-error-stop pgloader_schema && /usr/local/bin/pgloader --on-error-stop pgloader_data"

  LABEL maintainer="Dimitri Fontaine <dim@tapoueh.org>"
