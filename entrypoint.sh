#!/bin/bash

USER_ID=${LOCAL_USER_ID:-1000}
export HOME=/home/app

echo "Starting with UID : $USER_ID"

if [[ "$USER_ID" != "$(id -u app)" ]]; then
  usermod -u $USER_ID app;
  groupmod -g $USER_ID app;
  chown -R $USER_ID:$USER_ID $HOME
  usermod -g $USER_ID app;
fi

exec /usr/local/bin/gosu app "$@"
