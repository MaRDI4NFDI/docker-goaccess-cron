FROM alpine:3.16 AS builds

ARG GOACCESS_VERSION="1.6.2"

RUN apk add --no-cache \
    autoconf \
    automake \
    build-base \
    clang \
    clang-static \
    gettext-dev \
    gettext-static \
    git \
    libmaxminddb-dev \
    libmaxminddb-static \
    libressl-dev \
    linux-headers \
    ncurses-dev \
    ncurses-static \
    tzdata

# GoAccess
RUN wget -q "https://tar.goaccess.io/goaccess-${GOACCESS_VERSION}.tar.gz" -O goaccess.tar.gz && \
        tar -xzf goaccess.tar.gz && mv goaccess-${GOACCESS_VERSION} goaccess
WORKDIR /goaccess
RUN CC="clang" CFLAGS="-O3 -static" LIBS="$(pkg-config --libs openssl)" ./configure --prefix="" --enable-utf8 --with-openssl --enable-geoip=mmdb
RUN make && make DESTDIR=/dist install


# Container
FROM alpine:3.16

RUN apk add --no-cache bash

ENV TIMEZONE="CET" \
    DEFAULT_SCHEDULE="0 0 * * *"

# EXPOSE 7890
COPY --from=builds /dist /
COPY --from=builds /usr/share/zoneinfo /usr/share/zoneinfo
RUN cp "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime && \
        echo "$TIMEZONE" > /etc/timezone && echo "Date: $(date)."

RUN touch /var/log/cron.log

COPY entrypoint.sh /entrypoint.sh
COPY goaccess-wrapper.sh /bin/goaccess-wrapper.sh
RUN chmod +x /entrypoint.sh /goaccess-wrapper.sh

ENTRYPOINT ["/entrypoint.sh"]
