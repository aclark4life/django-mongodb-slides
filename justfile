# List available recipes
default:
    @just --list

# Print the connection URI for the "demo" mongodb-runner instance,
# starting one if it isn't already running. Leading underscore hides
# the recipe from `just --list`. The shebang turns the recipe body
# into a single bash script (instead of one shell per line) so the
# variable assignment and the if-block share state.
_uri:
    #!/usr/bin/env bash
    set -euo pipefail
    # Look up an already-running instance tagged --id demo.
    # `mongodb-runner ls` prints "<id>: <uri>" per line; awk pulls the URI.
    URI=$(mongodb-runner ls | awk -F': ' '/^demo: / {print $2}')
    # Nothing running? Start a fresh instance; its last stdout line is the URI.
    if [ -z "$URI" ]; then
        URI=$(mongodb-runner start --id demo | tail -n1)
    fi
    echo "$URI"

# Scaffold the demo project from the local template
startproject:
    django-admin startproject demo -v 3 --template templates/project_template

# Run the Django dev server with MONGODB_URI wired up
runserver:
    cd demo && MONGODB_URI="$(just _uri)" python manage.py runserver

# Apply migrations against the demo database
migrate:
    cd demo && MONGODB_URI="$(just _uri)" python manage.py migrate

# Drop the demo database (handy between demos)
dropdb:
    mongosh "$(just _uri)" --quiet --eval 'db.getSiblingDB("demo").dropDatabase()'
