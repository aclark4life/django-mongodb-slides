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

# Scaffold the demo project from the mongodb-labs/django-mongodb-project template
startproject:
    django-admin startproject demo -v 3 --template https://github.com/mongodb-labs/django-mongodb-project/archive/refs/heads/6.0.x.zip
    python3 -c "p='demo/demo/settings.py'; s=open(p).read(); open(p,'w').write('import os\n'+s)"
    sed -i '' "s|'HOST': 'mongodb://localhost:27017/'|'HOST': os.environ.get('MONGODB_URI', 'mongodb://localhost:27017')|" demo/demo/settings.py
    pip install ipython

# Install polls, wire it into the demo project's settings + urls, and seed data
polls:
    #!/usr/bin/env python3
    import os, pathlib, subprocess
    subprocess.run(["pip", "install", "-e", "../mongodb/polls"], check=True)
    s = pathlib.Path("demo/demo/settings.py")
    s.write_text(s.read_text().replace(
        "    'django_mongodb_backend',\n]",
        "    'django_mongodb_backend',\n    'polls',\n]"
    ))
    u = pathlib.Path("demo/demo/urls.py")
    u.write_text(u.read_text()
        .replace("from django.urls import path",
                 "from django.urls import include, path")
        .replace("path('admin/', admin.site.urls),",
                 "path('admin/', admin.site.urls),\n    path('polls/', include('polls.urls')),")
    )
    uri = subprocess.check_output(["just", "_uri"]).decode().strip()
    env = {**os.environ, "MONGODB_URI": uri}
    subprocess.run(["python", "manage.py", "migrate"], cwd="demo", env=env, check=True)
    subprocess.run(["python", "manage.py", "seed_polls"], cwd="demo", env=env, check=True)

# Run the Django dev server with MONGODB_URI wired up
runserver:
    cd demo && MONGODB_URI="$(just _uri)" python manage.py runserver

# Apply migrations against the demo database
migrate:
    cd demo && MONGODB_URI="$(just _uri)" python manage.py migrate

# Create Django superuser (admin / admin)
su:
    cd demo && MONGODB_URI="$(just _uri)" DJANGO_SUPERUSER_PASSWORD=admin python manage.py createsuperuser --noinput --username=admin --email=admin@example.com

# Open a Django shell against the demo database (IPython, vi key bindings)
shell:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p demo/.ipython/profile_default
    echo "c.TerminalInteractiveShell.editing_mode = 'vi'" > demo/.ipython/profile_default/ipython_config.py
    cd demo && IPYTHONDIR="$PWD/.ipython" MONGODB_URI="$(just _uri)" python manage.py shell -i ipython

# Open a MongoDB shell against the demo database
dbshell:
    mongosh "$(just _uri)demo"

# Drop the demo database (handy between demos)
dropdb:
    mongosh "$(just _uri)" --quiet --eval 'db.getSiblingDB("demo").dropDatabase()'

# Remove the generated demo project directory (start fresh with `just startproject`)
clean:
    rm -rvf demo

# Open the slides in the default browser
open:
    open index.html
