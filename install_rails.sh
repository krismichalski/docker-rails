#!/bin/bash

if [ ! -f /home/app/.rails_installed ]; then
  echo "Installing rails $RAILS_VERSION"
  su -m app -c 'gem install -N -i "$GEM_HOME" rails -v "$RAILS_VERSION"'
  touch /home/app/.rails_installed
fi
