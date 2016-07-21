#!/bin/bash

if [ "$TRAVIS_BRANCH" == "master" ]; then
  if [[ "$TAG" == "2.3"* ]]; then
    if [[ "$RAILS_VERSION" == "5.0" ]]; then
      export TAG_MAJOR=${TAG/.3/};
      curl -H "Content-Type: application/json" --data "{'docker_tag': ${TAG}}" -X POST https://registry.hub.docker.com/u/nooulaif/rails/trigger/${MY_DOCKERHUB_TOKEN}/;
      curl -H "Content-Type: application/json" --data "{'docker_tag': ${TAG_MAJOR}}" -X POST https://registry.hub.docker.com/u/nooulaif/rails/trigger/${MY_DOCKERHUB_TOKEN}/;
      curl -H "Content-Type: application/json" --data "{'docker_tag': 'latest'}" -X POST https://registry.hub.docker.com/u/nooulaif/rails/trigger/${MY_DOCKERHUB_TOKEN}/;
    fi
  else
    curl -H "Content-Type: application/json" --data "{'docker_tag': ${TAG}}" -X POST https://registry.hub.docker.com/u/nooulaif/rails/trigger/${MY_DOCKERHUB_TOKEN}/;
  fi
fi
