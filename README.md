# docker-rails

Minimal, ready to use [Docker](https://www.docker.com/) image for running [Ruby on Rails](http://rubyonrails.org/) (5 & 4) applications.
Based on [Alpine Linux](https://www.alpinelinux.org/).

Very light. Weighs only ~150MB, which is about 4 times less than [official image](https://hub.docker.com/_/rails/).

## Supported tags and respective `Dockerfile` links

- [`alpine-5.0-v002`, `alpine-5.0`, `alpine-5`, `latest`](https://github.com/nooulaif/docker-rails/blob/master/alpine-5.0.dockerfile)
- [`alpine-4.2-v002`, `alpine-4.2`, `alpine-4`](https://github.com/nooulaif/docker-rails/blob/master/alpine-4.2.dockerfile)

## Features
- Automatically creates and prepares new rails app
    * If in empty / with docker-compose.yml only folder
    * With correct app name of choise (based on environment variable APP_NAME)
    * Modyfies database.yml to use environment variables DB_ADAPTER, DB_HOST, DB_USER, DB_PASS
    * Ability to pass any additional arguments with RAILS_NEW_ARGS environment variable
- Nokogiri, BCrypt, PostgreSQL, MySQL and SQLite gems native extensions preinstalled
- On every restart checks if bundle install is necessary and if so runs it
- Runs rake db:migrate on every restart for quick development
- Modyfies log output to stdout and formats it for [Logstash](https://www.elastic.co/products/logstash)
- In development adds docker network as trusted for web console
- Includes [pry](http://pryrepl.org/) for easier debugging
    * In Alpine irb is buggy [(libedit-dev vs libreadline-dev)](https://github.com/docker-library/ruby/issues/75), so there is an alias to pry
- Creates user with UID and GUI 1000 so it matches defaults for first non-root user on Linux hosts
    * Thanks to that there are no problems with permissions on shared volumes (workaround until [docker solves this](https://github.com/docker/docker/issues/2259))

## Versions
- Ready:
    * alpine 3.4, ruby 2.3, rails 5.0.0
    * alpine 3.4, ruby 2.3, rails 4.2.6
- In plans:
    * debian jessie, ruby 2.3, rails 5.0.0
    * debian jessie, ruby 2.3, rails 4.2.6

## Quick start
Execute this command in empty folder:
```bash
docker run -it -v $(pwd):/home/app/webapp -p 3000:3000 nooulaif/rails:latest
```
Although I do recommend method with docker-compose.yml below which gives you possibility to
mount installed gems into shared volume for ever faster development.

## Example with [docker-compose](https://github.com/docker/compose) and all options
In new, empty folder add file docker-compose.yml with following content:
```yaml
version: '2'
services:
  api:
    image: nooulaif/rails:latest
    environment:
      - APP_NAME=example
      - DB_HOST=db # name of service below
      - DB_ADAPTER=postgresql
      # - DB_ADAPTER=mysql2
      # - DB_ADAPTER=sqlite3
      - DB_USER=postgres
      # - DB_USER=root
      # - DB_PASS=password
      # - RAILS_NEW_ARGS='--api'
    volumes:
      - ./:/home/app/webapp
      - bundle_data:/home/app/bundle
    depends_on:
      - db
    ports:
      - 3000:3000
    # for pry
    tty: true
    stdin_open: true

  # not needed when sqlite3
  db:
    image: postgres:9.5
    # image: mariadb:10.1
    # image: mysql:5.7
    volumes:
      - db_data:/var/lib/postgresql
      # - db_data:/var/lib/mysql
    # environment:
      # - MYSQL_ROOT_PASSWORD=password
      # or empty root password
      # - MYSQL_ALLOW_EMPTY_PASSWORD=yes

volumes:
  bundle_data:
    driver: local
  db_data:
    driver: local
```
Next run these commands:
```bash
docker-compose -p example up -d
docker attach example_api_1
```
To stop:
```bash
docker-compose stop
```
To completely remove:
```
docker-compose down -v # also removes volumes
```

## Modify existing rails project to use with this image
You need to add these gems to your Gemfile:
```ruby
gem 'pry-rails', '= 0.3.4', group: :development
gem 'nokogiri', '= 1.6.8'
gem 'lograge', '~> 0.3.6'
gem 'logstash-event', '~> 1.2.02'
```
Add these lines to config/application.rb:
```ruby
config.logger = Logger.new(STDOUT)
config.lograge.enabled = true
config.lograge.formatter = Lograge::Formatters::Logstash.new
```
And these to config/environments/development.rb:
```ruby
config.web_console.whitelisted_ips = "172.0.0.0/8" if defined?(WebConsole)
```
Lastly your config/database.yml must use environments variables like so:
```yaml
default: &default
  adapter: <%= ENV['DB_ADAPTER'] %>
  host: <%= ENV['DB_HOST'] %>
  username: <%= ENV['DB_USER'] %>
  password: <%= ENV['DB_PASS'] %>
```
And you need to set them appropriately.

Also make sure all files in bin/ directory uses:
```
#!/usr/bin/env ruby
```

## Gems with native extensions
If you ever encounter problem similar to this:
```
Gem::Ext::BuildError: ERROR: Failed to build gem native extension.
```
It means one of gems in your Gemfile requires some building libraries which, for the sake of size, this image do not provide.
However it's relatively easy to get this working and keep small image. You just need to build your image on top of this.

Create new file in root of your rails project and name it Dockerfile.
Inside it put something along the lines:
```dockerfile
FROM nooulaif/rails:latest
MAINTAINER you@example.com

RUN apk add --no-cache --virtual build-dependencies \
    build-base ruby-dev libc-dev \
 && gem install some-gem-with-native-extension \
 && apk del build-dependencies \
 && find / -type f -iname '*.apk-new' -delete \
 && rm -rf '/var/cache/apk/*'
```
And then in your docker-compose.yml instead of:
```yml
image: nooulaif/rails:latest
```
put:
```yml
build: .
```
Run:
```bash
docker-compose build && docker-compose up
```
and check if this solved a problem.
Don't forget to remove your bundle volume:
```bash
docker volume rm example_bundle_data # use docker volume ls to find yours
```
otherwise it will override your newly installed gem.

## Supported Docker versions
This image was tested with Docker version 1.11.2.

I would be very pleased to hear whether or not it works on older versions as well.

## Issues
If you have any problems with or questions about this image, please contact me through a [GitHub issue](https://github.com/nooulaif/docker-rails/issues).

## Contributing
You are invited to contribute new features, fixes, or updates, large or small.

I'm always thrilled to receive pull requests, and do my best to process them as fast as I can.

## License
Released under the MIT License. See [LICENSE](https://github.com/nooulaif/docker-rails/blob/master/LICENSE) file for details.
