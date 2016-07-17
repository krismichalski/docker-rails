FROM ruby:2.3-slim
MAINTAINER contact@nooulaif.com

# Set all environment variables at once
ENV RUBYGEMS_VERSION=2.6.4 \
    BUNDLER_VERSION=1.12.5 \
    RAILS_VERSION=5.0.0 \
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
 && su -m app -c 'gem install -N -i "$GEM_HOME" rails -v "$RAILS_VERSION"' \
 && apt-get clean \
 && rm -rf '/var/lib/apt/lists/*' '/tmp/*' '/var/tmp/*'

USER app
WORKDIR $APP

COPY start.sh template.rb /home/app/
CMD /home/app/start.sh
