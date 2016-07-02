#!/bin/bash
: ${APP_NAME:=example}
: ${DB_HOST:=}
: ${DB_ADAPTER:=sqlite3}
: ${DB_USER:=}
: ${DB_PASS:=}
: ${RAILS_NEW_ARGS:=}
RAILS_NEW_DB_ADAPTER=${DB_ADAPTER/mysql2/mysql}
RAILS_NEW_ARGS=${RAILS_NEW_ARGS%\"}
RAILS_NEW_ARGS=${RAILS_NEW_ARGS%\'}
RAILS_NEW_ARGS=${RAILS_NEW_ARGS#\"}
RAILS_NEW_ARGS=${RAILS_NEW_ARGS#\'}

# this is only run if in empty folder or with docker-compose.yml only
test "$(ls -A /home/app/webapp | grep -v 'docker-compose.yml')" || ( \
  rails new /home/app/$APP_NAME -B -m=/home/app/template.rb -d=$RAILS_NEW_DB_ADAPTER $RAILS_NEW_ARGS && \
  (mv /home/app/$APP_NAME/{*,.*} /home/app/webapp/ 2> /dev/null && rmdir /home/app/$APP_NAME); \
  sed -i "s/  adapter:\(.*\)/  adapter: <%= ENV['DB_ADAPTER'] %>/" /home/app/webapp/config/database.yml; \
  (sed -i "s/  password:\(.*\)/  password: <%= ENV['DB_PASS'] %>/" /home/app/webapp/config/database.yml && sed -i "s/  adapter\: <%\= ENV\['DB_ADAPTER'\] %>/  adapter: <%= ENV['DB_ADAPTER'] %>\n  password: <%= ENV['DB_PASS'] %>/" /home/app/webapp/config/database.yml); \
  (sed -i "s/  username:\(.*\)/  username: <%= ENV['DB_USER'] %>/" /home/app/webapp/config/database.yml && sed -i "s/  adapter\: <%\= ENV\['DB_ADAPTER'\] %>/  adapter: <%= ENV['DB_ADAPTER'] %>\n  username: <%= ENV['DB_USER'] %>/" /home/app/webapp/config/database.yml); \
  (sed -i "s/  host:\(.*\)/  host: <%= ENV['DB_HOST'] %>/" /home/app/webapp/config/database.yml && sed -i "s/  adapter\: <%\= ENV\['DB_ADAPTER'\] %>/  adapter: <%= ENV['DB_ADAPTER'] %>\n  host: <%= ENV['DB_HOST'] %>/" /home/app/webapp/config/database.yml); \
  (bundle check || (echo 'running bundle install...' && bundle install)) && rake db:create
)

# remove pids because sometimes they cause problems
rm -rf tmp/pids

# run bundle install, rake db:migrate and rails server on every start
(bundle check || (echo 'running bundle install...' && bundle install)) && rake db:migrate && rails server -p 3000 -b 0.0.0.0
