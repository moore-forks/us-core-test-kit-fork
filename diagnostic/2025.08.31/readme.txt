I ran a number of tests on a private VM that has Docker installed.
Log files are included in this folder.
These are the steps I ran


Forked to https://github.com/moore-forks/us-core-test-kit-fork.git
git clone https://github.com/moore-forks/us-core-test-kit-fork.git
cd us-core-test-kit-fork/
git checkout v1.0.0


=== First trial ====
=== SQLite, no changes to any files ===

- Do not touch .env nor any docker-compose file

./setup.sh
    Reports errors concerning SQLite3
./setup.sh 
    No errors this time

script /tmp/logs/v1.0.0.log
cat .env
git status
 
./run.sh
    Reports errors
    Nothing listening at port 80
exit

=== Second trial ====
=== SQLite, copy .env.production to .env ===

script /tmp/logs/v1.0.0-production.log
cp .env.production .env
cat .env
git status
./run.sh
    Reports errors
    Web browser to http://192.168.1.104 reports "502 Bad Gateway"
exit

=== Third trial ====
=== SQLite, cat .env.production >> .env ===

script /tmp/logs/v1.0.0-combination.log
git checkout -- .env
git status
cat .env.production >> .env
cat .env
git status
./run.sh
    Reports errors
    Nothing listening at port 80
exit

=== Fourth trial ====
=== Trying with Postgres ===

Made a branch for Postgres as that is what we want anyway

git checkout -- .env
git checkout -b v1.0.0-postgres v1.0.0
Modify three files for Postgres
 - Gemfile
 - config/database.yml
 - docker-compose.yml

script /tmp/logs/pg-setup.log

./setup.sh
Complained about missing 'pg' gem for some platforms
Removed from PLATFORMS in Gemfile.lock
 - arm64-darwin-21
 - x86_64-darwin-20
 - ruby

./setup.sh
 - Ran to completion

./run.sh
 - Reports errors
 - Web browser to http://192.168.1.104 reports "502 Bad Gateway"
exit

=== Fourth trial ====
=== Trying with Postgres and production environment  ===


script /tmp/logs/pg.log
git status
cp .env.production .env
./setup.sh
docker ps
 - Two containers were running, so I killed them
docker kill xxx yyy
docker ps
 - No containers running

./run.sh
 - Nothing listening at port 80

docker ps
CONTAINER ID   IMAGE                                         COMMAND                  CREATED          STATUS              PORTS      NAMES
7f038ca2ec73   postgres:14.1-alpine                          "docker-entrypoint.s…"   16 minutes ago   Up About a minute   5432/tcp   us-core-test-kit-fork-inferno_db-1
94c21bb3f84f   infernocommunity/inferno-resource-validator   "/__cacert_entrypoin…"   49 minutes ago   Up About a minute   3500/tcp   us-core-test-kit-fork-hl7_validator_service-1

docker compose exec inferno_db /bin/sh
su - postgres
psql --list
 - shows inferno_production
psql -c "\\d" inferno_production
 - shows relations in database

