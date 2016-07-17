# docker-rails

Ready to use [Docker](https://www.docker.com/) image for running [Ruby on Rails](http://rubyonrails.org/) (5 & 4) applications.
Based on [official Ruby images](https://hub.docker.com/_/ruby/).

## Supported tags and respective `Dockerfile` links

- [`5`, `latest`](https://github.com/nooulaif/docker-rails/blob/master/5.dockerfile)
- [`5-slim`](https://github.com/nooulaif/docker-rails/blob/master/5-slim.dockerfile)
- [`5-alpine`](https://github.com/nooulaif/docker-rails/blob/master/5-alpine.dockerfile)
- [`4`](https://github.com/nooulaif/docker-rails/blob/master/4.dockerfile)
- [`4-slim`](https://github.com/nooulaif/docker-rails/blob/master/4-slim.dockerfile)
- [`4-alpine`](https://github.com/nooulaif/docker-rails/blob/master/4-alpine.dockerfile)

## Features
- Automatically creates and prepares new rails app
    * If in empty / with docker-compose.yml only folder
    * With correct app name of choise (based on environment variable APP_NAME)
    * Modyfies database.yml to use environment variables DB_ADAPTER, DB_HOST, DB_USER, DB_PASS
    * Ability to pass any additional arguments with RAILS_NEW_ARGS environment variable
- On every restart checks if bundle install is necessary and if so runs it
- Runs rake db:migrate on every restart for quick development
- Modyfies log output to stdout and formats it for [Logstash](https://www.elastic.co/products/logstash)
- In development adds docker network as trusted for web console
- Includes [pry](http://pryrepl.org/) for easier debugging
- Creates user with UID and GUI 1000 so it matches defaults for first non-root user on Linux hosts
    * Thanks to that there are no problems with permissions on shared volumes (workaround until [docker solves this](https://github.com/docker/docker/issues/2259))

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
  app:
    image: nooulaif/rails:latest
    environment:
      - APP_NAME=example
      - DB_HOST=db # name of service below
      - DB_ADAPTER=postgresql
      # - DB_ADAPTER=mysql2
      # - DB_ADAPTER=sqlite3
      - DB_USER=postgres
      # - DB_USER=root # for mysql
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
    logging:
      driver: none

volumes:
  bundle_data:
    driver: local
  db_data:
    driver: local
```
Next run these commands:
```bash
docker-compose -p example up -d
docker attach example_app_1
```
To stop:
```bash
docker-compose stop
```
To completely remove:
```
docker-compose down
docker-compose down -v # also removes volumes
```

## Modify existing rails project to use with this image
You need to add these gems to your Gemfile:
```ruby
gem 'pry-byebug', '~> 3.4.0', group: :development
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
If you need to recreate database run:
```bash
docker-compose run --rm app /bin/bash -c 'bundle install && rake db:create'
```

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
