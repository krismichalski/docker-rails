#!/bin/bash

echo "$TRAVIS_BRANCH"
echo "$TAG"
echo "$RAILS_VERSION"

echo '0'

if [ "$TRAVIS_BRANCH" == "master" ]; then
  echo '1'
  if [[ "$TAG" == "2.3"* ]]; then
    echo '2'
    if [[ "$RAILS_VERSION" == "5.0" ]]; then
      echo '3'
      export TAG_MAJOR=${TAG/.3/};
      echo "$TAG_MAJOR"
      curl -H "Content-Type: application/json" --data "{'docker_tag': ${TAG}}" -X POST https://registry.hub.docker.com/u/nooulaif/rails/trigger/${MY_DOCKERHUB_TOKEN}/;
      curl -H "Content-Type: application/json" --data "{'docker_tag': ${TAG_MAJOR}}" -X POST https://registry.hub.docker.com/u/nooulaif/rails/trigger/${MY_DOCKERHUB_TOKEN}/; fi;
      curl -H "Content-Type: application/json" --data "{'docker_tag': 'latest'}" -X POST https://registry.hub.docker.com/u/nooulaif/rails/trigger/${MY_DOCKERHUB_TOKEN}/; fi;
    fi
  else
    echo '4'
    curl -H "Content-Type: application/json" --data "{'docker_tag': ${TAG}}" -X POST https://registry.hub.docker.com/u/nooulaif/rails/trigger/${MY_DOCKERHUB_TOKEN}/; fi;
  fi
fi

echo '5'
