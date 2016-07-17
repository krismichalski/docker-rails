#!/bin/bash

USER_ID=${LOCAL_USER_ID:-1000}
export HOME=/home/app

echo "Starting with UID : $USER_ID"

if [[ "$USER_ID" != "$(id -u app)" ]]; then
  if [[ "$(cat /etc/issue | grep 'Alpine')" ]]; then
    deluser app;
    addgroup -g $USER_ID app;
    adduser -u $USER_ID -D -G app -s /bin/bash app;
    chown -R app:app /home/app;
  else
    usermod -u $USER_ID app;
    groupmod -g $USER_ID app;
    chown -R $USER_ID:$USER_ID $HOME
    usermod -g $USER_ID app;
  fi
fi

exec /usr/local/bin/gosu app "$@"
