# docker-rails [![Build Status](https://travis-ci.org/krismichalski/docker-rails.svg?branch=master)](https://travis-ci.org/krismichalski/docker-rails)

Ready to use [Docker](https://www.docker.com/) image for running [Ruby on Rails](http://rubyonrails.org/) applications.
Based on [official Ruby images](https://hub.docker.com/_/ruby/).

## Supported tags

- [`2.4`, `2`, `latest`](https://github.com/krismichalski/docker-rails/blob/master/2.4.dockerfile)
- [`2.4-slim`, `2-slim`](https://github.com/krismichalski/docker-rails/blob/master/2.4-slim.dockerfile)
- [`2.4-alpine`, `2-alpine`](https://github.com/krismichalski/docker-rails/blob/master/2.4-alpine.dockerfile)
- [`2.3`](https://github.com/krismichalski/docker-rails/blob/master/2.3.dockerfile)
- [`2.3-slim`](https://github.com/krismichalski/docker-rails/blob/master/2.3-slim.dockerfile)
- [`2.3-alpine`](https://github.com/krismichalski/docker-rails/blob/master/2.3-alpine.dockerfile)
- [`2.2`](https://github.com/krismichalski/docker-rails/blob/master/2.2.dockerfile)
- [`2.2-slim`](https://github.com/krismichalski/docker-rails/blob/master/2.2-slim.dockerfile)
- [`2.2-alpine`](https://github.com/krismichalski/docker-rails/blob/master/2.2-alpine.dockerfile)

## Experimental tags (no longer supported)

- [`5-mini`](https://github.com/krismichalski/docker-rails/blob/master/5-mini.dockerfile)
- [`4-mini`](https://github.com/krismichalski/docker-rails/blob/master/4-mini.dockerfile)

## Features
- Does not comes with any pre-installed version of rails, so you can choose by yourself
- Uses [gosu](https://github.com/tianon/gosu) to better handle su and sudo commands
- Automatically creates and prepares new rails app
- Runs bundle install & rake db:migrate on every restart for quick development
- For production modifies log output to stdout and formats it for [Logstash](https://www.elastic.co/products/logstash)
- In development adds docker network as trusted for web console
- Includes [pry](http://pryrepl.org/) for easier debugging
- Solves problem with wrong permissions on shared volumes by matching UIDs

## Quick start
Execute this command in empty folder:
```bash
docker run -it -v $(pwd):/home/app/webapp -p 3000:3000 krismichalski/rails:latest
```

## Environment variables

When you start this image, you can adjust some of the behavior
by passing one or more environment variables.

### RAILS_VERSION

Default: Based on ruby version.

| Ruby version | Default rails version |
|:------------:|:---------------------:|
|      2.4     |         ~> 5.1        |
|      2.3     |         ~> 5.0        |
|      2.2     |         ~> 4.2        |

You can specify what version of rails you want to install.

Installation will occur once and only if run command wasn't
changed or it starts with `rails`, `rake` or `bundle`.

Note: Has no effect in mini versions, because they have rails pre-installed.

### APP_NAME

Default: `webapp`

By default rails creates app name, which determines e.g. databases names, based on folder name where rails new command was run.

In case of this image it would be `module Webapp`. This setting lets you overwrite this.

### RAILS_NEW_ARGS

Default: `[empty string]`

You can specify additional arguments to rails new command.

For example `RAILS_NEW_ARGS="--api --skip-spring"`

### DEFAULT_RAILS_NEW_IGNORED_FILES

Default: `,docker-compose.yml,.bundle,Dockerfile,.git,.svn,.hg`

To avoid problems with overwriting files this image runs rails new command only
if certain set of files is present in mounted volume. If anything besides these
files is present rails new command will not be triggered.

### RAILS_NEW_IGNORED_FILES

Default: `[empty string]`

You can add additional files to white-list when checking for rails new command to run.

For example `RAILS_NEW_IGNORED_FILES=Dockerfile.production,compose-production.yml`

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

Notice: it's not value passed to rails new command, but to database.yml file.

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
Consult [official readme](https://hub.docker.com/_/ruby/) for difference between
`<version>`, `<version>-slim` and `<version>-alpine` images.

### Mini (no longer supported)
These images are more of an experiment to create smallest, usable image for rails.

With the size about 150MB, these are ~4 times thinner than [official rails images](https://hub.docker.com/_/rails/).

## Tips for quick development
Instead of installing every single gem from Gemfile each time you want to add new one,
I recommend to create docker volume and mount it to /home/app/bundle.
Thanks to that you can install only new gems.

See [example docker-compose.yml](https://github.com/krismichalski/docker-rails/blob/master/example-compose.yml)
for a way to achieve this.

Also to avoid installing rails over and over again it's probably a good idea to place below Dockerfile in root of your app
and use image build with it.

```Dockerfile
FROM krismichalski/rails:latest
ENV RAILS_VERSION=5.1.0
RUN /home/app/install_rails.sh
```

## Supported Docker versions
This image was tested with Docker version 17.04 and should work with any version above 1.11.2

I would be very pleased to hear whether or not it works on older versions as well.

## Issues
If you have any problems with or questions about this image, please contact me through a [GitHub issue](https://github.com/krismichalski/docker-rails/issues).

## Contributing
You are invited to contribute new features, fixes, or updates, large or small.

I'm always thrilled to receive pull requests, and do my best to process them as fast as I can.

## License
Released under the MIT License. See [LICENSE](https://github.com/krismichalski/docker-rails/blob/master/LICENSE) file for details.
