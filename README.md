# docker-rails

Minimal, ready to use [Docker](https://www.docker.com/) image for running [Ruby on Rails](http://rubyonrails.org/) applications.
Based on [Alpine Linux](https://www.alpinelinux.org/). Very light. Weighs only ~150MB, which is about 4 times less than [official image](https://hub.docker.com/_/rails/).

## Features
- Automatically creates and prepares new rails app
    * Only if in empty / with docker-compose.yml only folder
    * With correct app name of choise (based on environment variable APP_NAME)
    * Modyfies database.yml to use environment variables DB_ADAPTER, DB_HOST, DB_USER, DB_PASS
    * Ability to pass any additional arguments with RAILS_NEW_ARGS environment variable
- Nokogiri, BCrypt, PostgreSQL, MySQL and SQLite gems native extensions preinstalled
- On every restart checks if bundle install is necessary and if so runs it
- Runs rake db:migrate on every restart for quick development
- Modyfies log output to stdout and formats it for [Logstash](https://www.elastic.co/products/logstash)
- In development adds docker network as trusted for web console
- Includes [pry](http://pryrepl.org/) for easier debugging
    * In Alpine irb is buggy [libedit-dev vs libreadline-dev](https://github.com/docker-library/ruby/issues/75), so there is an alias to pry
- Creates user with UID and GUI 1000 so it match defaults for first non-root user on Linux hosts
    * Thanks to that there are no problems with permissions on shared volumes (workaround until [docker solves this](https://github.com/docker/docker/issues/2259))

## Versions
- Ready:
    * alpine 3.4, ruby 2.3, rails 5.0.0
- In plans:
    * debian jessie, ruby 2.3, rails 5.0.0

## Example docker-compose.yml with all options
```yaml
version: '2'
services:
  api:
    image: nooulaif/rails:5.0.0
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
      - bundle:/home/app/bundle
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
  bundle:
    driver: local
  db_data:
    driver: local
```
```bash
docker-compose -p example up -d
docker attach example_api_1
```

## License
Released under the MIT License See [LICENSE](LICENSE) file for details.
