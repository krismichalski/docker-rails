#!/bin/bash
: ${APP_NAME:=webapp}
: ${DB_HOST:=}
: ${DB_ADAPTER:=sqlite3}
: ${DB_USER:=}
: ${DB_PASS:=}
: ${RAILS_NEW_ARGS:=}
: ${RAILS_NEW_IGNORED_FILES:=}
: ${PREPARE_ONLY:=false}
: ${DEFAULT_RAILS_NEW_IGNORED_FILES:=,docker-compose.yml,.bundle,Dockerfile,.git,.svn,.hg}
RAILS_NEW_IGNORED_FILES+=$DEFAULT_RAILS_NEW_IGNORED_FILES
RAILS_NEW_IGNORED_FILES=${RAILS_NEW_IGNORED_FILES//,/\\\|}
RAILS_NEW_DB_ADAPTER=${DB_ADAPTER/mysql2/mysql}
RAILS_NEW_ARGS=${RAILS_NEW_ARGS%\"}
RAILS_NEW_ARGS=${RAILS_NEW_ARGS%\'}
RAILS_NEW_ARGS=${RAILS_NEW_ARGS#\"}
RAILS_NEW_ARGS=${RAILS_NEW_ARGS#\'}

# this runs if in empty folder or with docker-compose.yml only
test "$(ls -A /home/app/webapp | grep -v $RAILS_NEW_IGNORED_FILES)" || ( \
  rails new /home/app/$APP_NAME -B -m=/home/app/template.rb -d=$RAILS_NEW_DB_ADAPTER $RAILS_NEW_ARGS && \
  if [[ "$APP_NAME" != "webapp" ]]; then (mv /home/app/$APP_NAME/{*,.*} /home/app/webapp/ 2> /dev/null && rmdir /home/app/$APP_NAME); fi; \
  sed -i "s/  adapter:\(.*\)/  adapter: <%= ENV['DB_ADAPTER'] %>/" /home/app/webapp/config/database.yml; \
  (sed -i "s/  password:\(.*\)/  password: <%= ENV['DB_PASS'] %>/" /home/app/webapp/config/database.yml && sed -i "s/  adapter\: <%\= ENV\['DB_ADAPTER'\] %>/  adapter: <%= ENV['DB_ADAPTER'] %>\n  password: <%= ENV['DB_PASS'] %>/" /home/app/webapp/config/database.yml); \
  (sed -i "s/  username:\(.*\)/  username: <%= ENV['DB_USER'] %>/" /home/app/webapp/config/database.yml && sed -i "s/  adapter\: <%\= ENV\['DB_ADAPTER'\] %>/  adapter: <%= ENV['DB_ADAPTER'] %>\n  username: <%= ENV['DB_USER'] %>/" /home/app/webapp/config/database.yml); \
  (sed -i "s/  host:\(.*\)/  host: <%= ENV['DB_HOST'] %>/" /home/app/webapp/config/database.yml && sed -i "s/  adapter\: <%\= ENV\['DB_ADAPTER'\] %>/  adapter: <%= ENV['DB_ADAPTER'] %>\n  host: <%= ENV['DB_HOST'] %>/" /home/app/webapp/config/database.yml); \
  (bundle check || (echo 'running bundle install...' && bundle install)) && rake db:create
)

if [[ "$PREPARE_ONLY" != "true" ]]; then
  # remove pids because sometimes they cause problems
  rm -rf tmp/pids

  # wait 3 seconds for database to start unless sqlite3
  if [[ "$DB_ADAPTER" != "sqlite3" ]]; then sleep 3; fi

  # run bundle install, rake db:migrate and rails server on every start
  (bundle check || (echo 'running bundle install...' && bundle install)) && rake db:migrate && rails server -p 3000 -b 0.0.0.0
fi
