default:
    @just --list

startproject:
    django-admin startproject demo -v 3 --template templates/project_template

runserver:
    #!/usr/bin/env bash
    set -euo pipefail
    URI=$(mongodb-runner ls | awk -F': ' '/^demo: / {print $2}')
    if [ -z "$URI" ]; then
        URI=$(mongodb-runner start --id demo | tail -n1)
    fi
    cd demo && MONGODB_URI="$URI" python manage.py runserver
