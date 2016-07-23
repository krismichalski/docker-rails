FROM ruby:2.2-alpine
MAINTAINER contact@nooulaif.com

# Set all environment variables at once
ENV GOSU_VERSION=1.9 \
    GEM_HOME=/home/app/bundle \
    BUNDLE_PATH=/home/app/bundle \
    BUNDLE_APP_CONFIG=/home/app/bundle \
    APP=/home/app/webapp \
    PATH=/home/app/webapp/bin:/home/app/bundle/bin:$PATH \
    DB_ADAPTER=sqlite3

# Install bash, less, nodejs, db clients and gosu
# Create app directory and set permissions
# Remove cache
RUN apk add --no-cache \
    bash less nodejs \
    build-base ruby-dev \
    libc-dev libffi-dev \
    sqlite-dev postgresql-dev mysql-dev \
    libxml2-dev libxslt-dev \
    tzdata \
    dpkg gnupg openssl \
 && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
 && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
 && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
 && export GNUPGHOME="$(mktemp -d)" \
 && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
 && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
 && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
 && chmod +x /usr/local/bin/gosu \
 && gosu nobody true \
 && addgroup -g 1000 app \
 && adduser -u 1000 -D -G app -s /bin/bash app \
 && mkdir -p "$APP" "$GEM_HOME/bin" \
 && { \
    echo 'install: --no-document'; \
    echo 'update: --no-document'; \
  } >> /home/app/.gemrc \
 && chown -R app:app /home/app \
 && find / -type f -iname '*.apk-new' -delete \
 && rm -rf '/var/cache/apk/*' '/tmp/*' '/var/tmp/*'

WORKDIR $APP
COPY start.sh template.rb entrypoint.sh install_rails.sh /home/app/

ENTRYPOINT ["/home/app/entrypoint.sh"]
CMD ["/home/app/start.sh"]
