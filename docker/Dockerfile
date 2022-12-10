# docker build -t gearman-docker --build-arg BUILDKIT_INLINE_CACHE=1 -f ./docker/Dockerfile . && docker run --rm -it gearman-docker
FROM alpine:3.17

ARG GEARMAN_VERSION
ENV GEARMAN_VERSION=$GEARMAN_VERSION

ENV TERM="xterm-256color" \
LANGUAGE="en_US.UTF-8" \
LANG="en_US.UTF-8" \
LC_TIME="en_DK.UTF-8" \
TIME_STYLE="long-iso"

ENV WORKDIR=/app/
WORKDIR ${WORKDIR}

RUN set -eux \
  && apk add --quiet --no-cache \
    bash \
    tzdata \
    nano \
    iputils \
    tini

RUN set -eux \
    && apk add --quiet --no-cache --virtual .build-deps \
        curl \
        ca-certificates \
        alpine-sdk \
        gperf \
        boost-dev \
        libevent-dev \
        util-linux-dev \
        hiredis-dev \
        mariadb-dev \
        libmemcached-dev \
    && curl -fsSL https://github.com/gearman/gearmand/releases/download/${GEARMAN_VERSION}/gearmand-${GEARMAN_VERSION}.tar.gz --output /tmp/gearmand.tar.gz \
    && mkdir -p /tmp/gearmand/ \
    && tar -xzf /tmp/gearmand.tar.gz -C /tmp/gearmand/ --strip-components=1 \
    && cd /tmp/gearmand/ \
    && ./configure \
    		--sysconfdir=/etc \
    		--localstatedir=/var \
    		--with-mysql=yes \
    		--with-postgresql=no \
    		--disable-libpq \
    		--disable-libtokyocabinet \
    		--disable-libdrizzle \
    		--enable-ssl \
    		--enable-hiredis \
    		--enable-jobserver=no \
    && make \
    && make install \
    && cd ${WORKDIR} && rm -rf /tmp/gearmand.tar.gz /tmp/gearmand/ \
    && RUNDEPS="$( \
        scanelf --needed --nobanner --recursive /usr/local \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && apk add --quiet --no-cache --virtual .gearmand-rundeps ${RUNDEPS} \
    && apk del .build-deps \
    && gearmand --version \
    && nproc

# set bash as a default shell
RUN set -eux \
    && echo "" > /root/.ash_history \
    && sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd

# setup user
ARG APP_UID=1000
ARG APP_GID=1000
RUN addgroup -g $APP_GID user && adduser -D -G user -u $APP_UID user && chown user:user ./

# environment
ENV HOME /home/user

LABEL org.opencontainers.image.title="Gearman Docker image" \
    org.opencontainers.image.description="Gearman Docker image" \
    org.opencontainers.image.authors="https://github.com/beeyev" \
    org.opencontainers.image.documentation="https://github.com/phplegacy/gearman-docker" \
    org.opencontainers.image.url="https://github.com/phplegacy/gearman-docker" \
    org.opencontainers.image.source="https://github.com/phplegacy/gearman-docker"

ARG TZ='UTC'
ENV TZ=$TZ

#These params meant to be set by CI
ARG BUILD_DATE
ENV BUILD_DATE=$BUILD_DATE
RUN echo $BUILD_DATE
ARG BUILD_FINGERPRINT
ENV BUILD_FINGERPRINT=$BUILD_FINGERPRINT
RUN echo $BUILD_FINGERPRINT

HEALTHCHECK --start-period=60s CMD gearadmin --status || exit 1

# entrypoint init
COPY --chmod=0755 ./docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN touch /etc/gearmand.conf && chown user:user /etc/gearmand.conf
ENTRYPOINT ["docker-entrypoint.sh"]

USER user
CMD ["gearmand"]
