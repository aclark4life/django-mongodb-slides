default:
    @just --list

startproject:
    django-admin startproject demo -v 3 --template templates/project_template

_uri:
    #!/usr/bin/env bash
    set -euo pipefail
    URI=$(mongodb-runner ls | awk -F': ' '/^demo: / {print $2}')
    if [ -z "$URI" ]; then
        URI=$(mongodb-runner start --id demo | tail -n1)
    fi
    echo "$URI"

runserver:
    cd demo && MONGODB_URI="$(just _uri)" python manage.py runserver

migrate:
    cd demo && MONGODB_URI="$(just _uri)" python manage.py migrate

dropdb:
    mongosh "$(just _uri)" --quiet --eval 'db.getSiblingDB("demo").dropDatabase()'
