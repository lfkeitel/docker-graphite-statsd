FROM phusion/baseimage:0.9.21
MAINTAINER Lee Keitel <lee@onesimussystems.com>

# dependencies
RUN apt-get -y update && \
    apt-get -y --force-yes install \
    vim \
    nginx \
    python \
    python-dev \
    python-flup \
    python-pip \
    python-cffi \
    expect \
    git \
    memcached \
    sqlite3 \
    libcairo2 \
    libcairo2-dev \
    python-cairo \
    pkg-config \
    nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install graphite-api
RUN pip install graphite-api gunicorn

# install whisper
RUN git clone -b 1.0.1 https://github.com/graphite-project/whisper.git /usr/local/src/whisper && \
    cd /usr/local/src/whisper && \
    pip install -r requirements.txt && \
    python ./setup.py install

# install carbon
RUN git clone -b 1.0.1 https://github.com/graphite-project/carbon.git /usr/local/src/carbon && \
    cd /usr/local/src/carbon && \
    pip install -r requirements.txt && \
    python ./setup.py install

# install statsd
#RUN git clone -b v0.7.2 https://github.com/etsy/statsd.git /opt/statsd
#ADD conf/statsd/config.js /opt/statsd/config.js

# config nginx
RUN rm /etc/nginx/sites-enabled/default
ADD conf/nginx/nginx.conf /etc/nginx/nginx.conf
ADD conf/nginx/graphite.conf /etc/nginx/sites-available/graphite.conf
ADD conf/nginx/.htpasswd /etc/nginx/.htpasswd
RUN ln -s /etc/nginx/sites-available/graphite.conf /etc/nginx/sites-enabled/graphite.conf

# logging support
RUN mkdir -p /var/log/carbon /var/log/graphite /var/log/nginx
ADD conf/logrotate /etc/logrotate.d/graphite

# daemons
ADD daemons/carbon.sh /etc/service/carbon/run
ADD daemons/carbon-aggregator.sh /etc/service/carbon-aggregator/run
ADD daemons/graphite.sh /etc/service/graphite/run
# ADD daemons/statsd.sh /etc/service/statsd/run
ADD daemons/nginx.sh /etc/service/nginx/run

COPY conf/graphite/ /opt/graphite/conf/
COPY conf/graphite-api.yaml /etc/graphite-api.yaml

# cleanup
RUN rm -rf /tmp/* /var/tmp/*

# defaults
EXPOSE 80 2003-2004 2023-2024 8125/udp 8126
VOLUME ["/opt/graphite", "/etc/nginx", "/etc/logrotate.d", "/var/log"]
ENV HOME /root
CMD ["/sbin/my_init"]
