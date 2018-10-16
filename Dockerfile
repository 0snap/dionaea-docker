FROM debian:stretch as install

RUN apt-get update && apt-get install -y \
    build-essential \
    ca-certificates \
    check \
    cmake \
    cython3 \
    git \
    libcurl4-openssl-dev \
    libemu-dev \
    libev-dev \
    libglib2.0-dev \
    libloudmouth1-dev \
    libnetfilter-queue-dev \
    libnl-3-dev \
    libpcap-dev \
    libssl-dev \
    libtool \
    libudns-dev \
    python3-dev \
    --no-install-recommends

# get latest dionaea from source
RUN git clone https://github.com/DinoTools/dionaea.git /opt/dionaea-git

WORKDIR /opt/dionaea-git/build
RUN cmake -DCMAKE_INSTALL_PREFIX:PATH=/opt/dionaea .. && \
    make && \
    make install

FROM debian:stretch
RUN apt-get update && apt-get -y install \
    ca-certificates \
    curl \
    libemu2 \
    libev4 \
    libglib2.0-0 \
    libloudmouth1-0 \
    libnetfilter-queue1 \
    libnl-3-200 \
    libpcap0.8 \
    libpython3.5 \
    libssl1.0.2 \
    libtool \
    libudns0 \
    procps \
    python3 \
    python3-bson \
    python3-sqlalchemy \
    python3-yaml \
    ttf-liberation \
    --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=install /opt/dionaea /opt/dionaea

# standard ports
EXPOSE 21
EXPOSE 80
EXPOSE 443
EXPOSE 445
EXPOSE 3306
# memcache
EXPOSE 11211
# mongo
EXPOSE 27017
# ms sql
EXPOSE 1443

# black hole - catch 'em all!
EXPOSE 23
EXPOSE 53
EXPOSE 53/udp
EXPOSE 123/udp

RUN mkdir -p /var/dionaea/binaries \
    /var/dionaea/bitstreams \
    /var/dionaea/logs \
    /var/dionaea/roots/ftp/root \
    /var/dionaea/roots/http/root

RUN rm -rf /opt/dionaea/etc/dionaea/services-enabled && \
    rm -rf /opt/dionaea/etc/dionaea/ihandlers-enabled && \
    rm -rf /opt/dionaea/lib/dionaea/python/dionaea/log_db_sql && \
    rm /opt/dionaea/lib/dionaea/python/dionaea/logsql.py && \
    rm /opt/dionaea/lib/dionaea/python/dionaea/mirror.py && \
    rm /opt/dionaea/lib/dionaea/python/dionaea/p0f.py && \
    rm /opt/dionaea/lib/dionaea/python/dionaea/tftp.py && \
    rm -rf /opt/dionaea/lib/dionaea/python/dionaea/upnp

COPY config/ihandlers /opt/dionaea/etc/dionaea/ihandlers-enabled
COPY config/services /opt/dionaea/etc/dionaea/services-enabled
COPY config/dionaea.cfg /opt/dionaea/etc/dionaea/dionaea.cfg

CMD /opt/dionaea/bin/dionaea -l info -L '*' -c /opt/dionaea/etc/dionaea/dionaea.cfg
