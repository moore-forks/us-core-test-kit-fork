#!/bin/sh
docker compose pull
docker compose build
docker compose run inferno bundle exec rake db:migrate

sudo chown -R 999:999 data/redis
