FROM debian:jessie
MAINTAINER John Alberts <john@alberts.me>

ENV PATH /opt/sensu/embedded/bin:$PATH

RUN apt-get update && \
  apt-get install -y wget ca-certificates && \
  wget -q http://repositories.sensuapp.org/apt/pubkey.gpg -O-  | apt-key add - && \
  echo "deb     http://repositories.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list && \
  apt-get update && \
  apt-get install -y sensu libxml2 libxml2-dev libxslt1-dev zlib1g-dev build-essential && \
  gem install --no-ri --no-rdoc nokogiri yaml2json && \
  apt-get remove --purge -y libxml2-dev libxslt1-dev zlib1g-dev $(apt-mark showauto) && rm -rf /var/lib/apt/lists/*
  apt-get autoremove -y && \
  apt-get -y clean && \
  wget https://github.com/jwilder/dockerize/releases/download/v0.0.2/dockerize-linux-amd64-v0.0.2.tar.gz && \
  tar -C /usr/local/bin -xzvf dockerize-linux-amd64-v0.0.2.tar.gz && \
  rm -f dockerize-linux-amd64-v0.0.2.tar.gz

ENV DEFAULT_PLUGINS_REPO sensu-plugins
ENV DEFAULT_PLUGINS_VERSION master

ADD templates /etc/sensu/templates
ADD bin /bin/

#Plugins needed for handlers
RUN /bin/install mailer

#Plugins needed for checks and maybe handlers
RUN /bin/install http

EXPOSE 4567
VOLUME ["/etc/sensu/conf.d"]

#Client Config
ENV CLIENT_SUBSCRIPTIONS all,default
ENV CLIENT_BIND 127.0.0.0

#Common Config
ENV RUNTIME_INSTALL ''
ENV LOG_LEVEL warn
ENV EMBEDDED_RUBY true
ENV CONFIG_FILE /etc/sensu/config.json
ENV CONFIG_DIR /etc/sensu/conf.d
ENV CHECK_DIR /etc/sensu/check.d
ENV EXTENSION_DIR /etc/sensu/extensions
ENV PLUGINS_DIR /etc/sensu/plugins
ENV HANDLERS_DIR /etc/sensu/handlers

#Config for gathering host metrics
ENV HOST_DEV_DIR /dev
ENV HOST_PROC_DIR /proc
ENV HOST_SYS_DIR /sys

ENTRYPOINT ["/bin/start"]
