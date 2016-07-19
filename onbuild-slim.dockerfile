FROM ruby:2.3-slim
MAINTAINER contact@nooulaif.com

# Set all environment variables at once
ENV GOSU_VERSION=1.9 \
    RUBYGEMS_VERSION=2.6.4 \
    BUNDLER_VERSION=1.12.5 \
    GEM_HOME=/home/app/bundle \
    BUNDLE_PATH=/home/app/bundle \
    BUNDLE_APP_CONFIG=/home/app/bundle \
    APP=/home/app/webapp \
    PATH=/home/app/webapp/bin:/home/app/bundle/bin:$PATH \
    DB_ADAPTER=sqlite3

# Install bash, less, nodejs, db clients for rails db command
#   and common build dependencies
# Create app directory and set permissions
# Install bundler, rails
# Remove cache
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    bash less nodejs \
    build-essential ruby-dev \
    libc-dev libffi-dev \
    mysql-client postgresql-client sqlite3 \
    libmysqlclient-dev libpq-dev libsqlite3-dev \
    libxml2-dev libxslt-dev \
    tzdata \
    ca-certificates wget \
 && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
 && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
 && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
 && export GNUPGHOME="$(mktemp -d)" \
 && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
 && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
 && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
 && chmod +x /usr/local/bin/gosu \
 && gosu nobody true \
 && addgroup --gid 1000 app \
 && adduser --gecos "" --uid 1000 --disabled-password --ingroup app --shell /bin/bash app \
 && mkdir -p "$APP" "$GEM_HOME/bin" \
 && { \
    echo 'install: --no-document'; \
    echo 'update: --no-document'; \
  } >> /home/app/.gemrc \
 && gem update -N --system $RUBYGEMS_VERSION \
 && chown -R app:app /home/app \
 && su -m app -c 'gem install -N -i "$GEM_HOME" bundler -v "$BUNDLER_VERSION"' \
 && apt-get clean \
 && rm -rf '/var/lib/apt/lists/*' '/tmp/*' '/var/tmp/*'

WORKDIR $APP
COPY start.sh template.rb entrypoint.sh /home/app/

ENTRYPOINT ["/home/app/entrypoint.sh"]
CMD ["/home/app/start.sh"]

ONBUILD COPY .rails-version /home/app
ONBUILD RUN su -m app -c 'gem install -N -i "$GEM_HOME" rails -v "$(cat /home/app/.rails-version)"'
