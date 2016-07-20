# docker-rails [![Build Status](https://travis-ci.org/nooulaif/docker-rails.svg?branch=travis-ci)](https://travis-ci.org/nooulaif/docker-rails)

Ready to use [Docker](https://www.docker.com/) image for running [Ruby on Rails](http://rubyonrails.org/) applications.
Based on [official Ruby images](https://hub.docker.com/_/ruby/).

## Supported tags and respective `Dockerfile` links

- [`2.3`, `2`, `latest`](https://github.com/nooulaif/docker-rails/blob/master/Dockerfile.2.3)
- [`2.3-slim`, `2-slim`](https://github.com/nooulaif/docker-rails/blob/master/Dockerfile.2.3-slim)
- [`2.3-alpine`, `2-alpine`](https://github.com/nooulaif/docker-rails/blob/master/Dockerfile.2.3-alpine)
- [`2.2`](https://github.com/nooulaif/docker-rails/blob/master/Dockerfile.2.2)
- [`2.2-slim`](https://github.com/nooulaif/docker-rails/blob/master/Dockerfile.2.2-slim)
- [`2.2-alpine`](https://github.com/nooulaif/docker-rails/blob/master/Dockerfile.2.2-alpine)
- [`2.1`](https://github.com/nooulaif/docker-rails/blob/master/Dockerfile.2.1)
- [`2.1-slim`](https://github.com/nooulaif/docker-rails/blob/master/Dockerfile.2.1-slim)
- [`2.1-alpine`](https://github.com/nooulaif/docker-rails/blob/master/Dockerfile.2.1-alpine)
- [`5-mini`](https://github.com/nooulaif/docker-rails/blob/master/Dockerfile.5-mini)
- [`4-mini`](https://github.com/nooulaif/docker-rails/blob/master/Dockerfile.4-mini)

## Features
- Uses [gosu](https://github.com/tianon/gosu) to better handle su and sudo commands
- Automatically creates and prepares new rails app
- Runs bundle install & rake db:migrate on every restart for quick development
- For production modyfies log output to stdout and formats it for [Logstash](https://www.elastic.co/products/logstash)
- In development adds docker network as trusted for web console
- Includes [pry](http://pryrepl.org/) for easier debugging
- Solves problem with wrong permissions on shared volume by matching UIDs

## Quick start
Execute this command in empty folder:
```bash
docker run -it -v $(pwd):/home/app/webapp -p 3000:3000 nooulaif/rails:latest
```

## Environment variables

When you start this image, you can adjust some of the behavior
by passing one or more environment variables.

### APP_NAME

Default: `example`

By defauly rails creates app name based on folder name where rails new command
was run. In case of this image it would be `module Webapp`. This setting lets
you overwrite this.

### RAILS_NEW_ARGS

Default: `[empty string]`

You can specify additional arguments to rails new command.
E.g. `RAILS_NEW_ARGS="--api --skip-spring"`

### DEFAULT_RAILS_NEW_IGNORED_FILES

Default: `,docker-compose.yml,.bundle,Dockerfile,.git,.svn,.hg`

To avoid problems with overwriting files this image runs rails new command only
if certain set of files is present in mounted volume. If anything besides these
files is present rails new command will not be triggered.

### RAILS_NEW_IGNORED_FILES

Default: `[empty string]`

You can add additional files to whitelist when checking for rails new command
to run. E.g. `RAILS_NEW_IGNORED_FILES=Dockerfile.production,compose-production.yml`

### LOCAL_USER_ID

Default: `1000`

You can change UID of default user to match your host user UID.

### PREPARE_ONLY

Default: `false`

You may wish to not run rails server after preparing app. To achieve this set
this variable to true.

### DB_ADAPTER

Default: `sqlite3`

Name of the database adapter to use with your app.

Notice: it's not value passed to rails new command, but to database.yml file

### DB_HOST

Default: `[empty string]`

Address to your database server.

### DB_USER

Default: `[empty string]`

User of your database.

### DB_PASS

Default: `[empty string]`

Password for your database user.

## Image variants

### Based on official docker ruby images
Consult [official readme](https://hub.docker.com/_/ruby/) for diffrence between
`<version>`, `<version>-slim` and `<version>-alpine` images.

### Mini
These images are more of an experiment to create smallest, usable image for rails.
With the size about 150MB, these are ~4 times thinner than [official rails images](https://hub.docker.com/_/rails/)
They are not officially supported, but I will update them from time to time to
meet rails dependencies.

## Tip for quick development
Instad of installing every single gem from Gemfile each time you want to add new one,
I recommend to create docker volume and mount it to /home/app/bundle.
This way you can install only new gems.
See [example docker-compose.yml](https://github.com/nooulaif/docker-rails/blob/master/example-compose.yml)
for a way to achieve this.

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
