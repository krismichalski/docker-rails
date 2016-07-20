FROM alpine:3.4
MAINTAINER contact@nooulaif.com

# Set all environment variables at once
ENV RUBY_MAJOR=2.3 \
    RUBY_VERSION=2.3.1 \
    RUBYGEMS_VERSION=2.6.4 \
    BUNDLER_VERSION=1.12 \
    RAILS_VERSION=4.2 \
    GEM_HOME=/home/app/bundle \
    BUNDLE_PATH=/home/app/bundle \
    BUNDLE_APP_CONFIG=/home/app/bundle \
    APP=/home/app/webapp \
    PATH=/home/app/webapp/bin:/home/app/bundle/bin:$PATH \
    DB_ADAPTER=sqlite3

# Install ruby2.3, bash, less, nodejs and gosu mini replacement
# Create app directory, set permissions and set alias to pry from irb
# Install bundler, rails, database adapters, nokogiri
#   and some other gems which require native extension building
# Remove cache
RUN apk add --no-cache \
    ruby=$RUBY_VERSION-r0 ruby-irb ruby-json ruby-rake \
    ruby-bigdecimal ruby-io-console tzdata \
    bash less nodejs \
    su-exec \
 && addgroup -g 1000 app \
 && adduser -u 1000 -D -G app -s /bin/bash app \
 && mkdir -p "$APP" "$GEM_HOME/bin" \
 && { \
    echo 'install: --no-document'; \
    echo 'update: --no-document'; \
  } >> /home/app/.gemrc \
 && echo 'alias irb=pry' >> /home/app/.bashrc \
 && echo 'alias gosu=su-exec' >> /home/app/.bashrc \
 && touch /home/app/.rails_installed \
 && mkdir -p /usr/local/bin/ \
 && ln -s $(which su-exec) /usr/local/bin/gosu \
 && gem update -N --system $RUBYGEMS_VERSION \
 && chown -R app:app /home/app \
 && apk add --no-cache --virtual build-dependencies \
    build-base ruby-dev \
    libc-dev libffi-dev \
    sqlite-dev postgresql-dev mysql-dev \
    libxml2-dev libxslt-dev \
 && su -m app -c 'gem install -N -i "$GEM_HOME" bundler -v "~> $BUNDLER_VERSION.0"' \
 && su -m app -c 'gem install -N -i "$GEM_HOME" rails -v "~> $RAILS_VERSION.0"' \
 && su -m app -c 'gem install -N -i "$GEM_HOME" pg -v "~> 0.18.4"' \
 && su -m app -c 'gem install -N -i "$GEM_HOME" mysql2 -v "~> 0.4.4"' \
 && su -m app -c 'gem install -N -i "$GEM_HOME" sqlite3 -v "~> 1.3.11"' \
 && su -m app -c 'gem install -N -i "$GEM_HOME" nokogiri -v "~> 1.6.8"' \
 && su -m app -c 'gem install -N -i "$GEM_HOME" binding_of_caller -v "~> 0.7.2"' \
 && su -m app -c 'gem install -N -i "$GEM_HOME" byebug -v "~> 9.0.5"' \
 && su -m app -c 'gem install -N -i "$GEM_HOME" ffi -v "~> 1.9.10"' \
 && su -m app -c 'gem install -N -i "$GEM_HOME" debug_inspector -v "~> 0.0.2"' \
 && su -m app -c 'gem install -N -i "$GEM_HOME" bcrypt -v "~> 3.1.11"' \
 && cd /usr/lib/ \
 && cp libldap_r-2.4.* liblber-2.4.* libsasl2.* libpq.* libmysqlclient.* libsqlite3.* /tmp/ \
 && apk del build-dependencies \
 && cd /tmp/ \
 && mv libldap_r-2.4.* liblber-2.4.* libsasl2.* libpq.* libmysqlclient.* libsqlite3.* /usr/lib/ \
 && find / -type f -iname '*.apk-new' -delete \
 && rm -rf '/var/cache/apk/*' '/tmp/*' '/var/tmp/*'

 WORKDIR $APP
 COPY start.sh template.rb entrypoint.sh /home/app/

 ENTRYPOINT ["/home/app/entrypoint.sh"]
 CMD ["/home/app/start.sh"]
