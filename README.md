# django-mongodb-slides

A [reveal.js](https://revealjs.com/) slide deck on building Django apps
on MongoDB with [`django-mongodb-backend`](https://github.com/mongodb/django-mongodb-backend).

The deck walks through install, configuration, the project template,
modeling with embedded documents and arrays, querying and aggregation,
indexes, constraints, what's new in the 6.0 series, and a runnable
[`polls`](https://github.com/aclark4life/polls) app demo.

## View the slides

```bash
just open
```

…or open `index.html` in any browser. There is no build step.

## Layout

| Path                                  | What it is                                  |
| ------------------------------------- | ------------------------------------------- |
| `index.html`                          | The deck (single file, CDN-hosted reveal.js) |
| `assets/mongodb/`                     | MongoDB brand SVGs                          |
| `assets/startproject-screenshot*.png` | Terminal screenshots used in the deck        |
| `templates/project_template/`         | Local copy of the MongoDB project template   |
| `justfile`                            | Recipes for the demo workflow                |

## `justfile` recipes

```
$ just
Available recipes:
    clean        # Remove the generated demo project directory (start fresh with `just startproject`)
    default      # List available recipes
    dropdb       # Drop the demo database (handy between demos)
    migrate      # Apply migrations against the demo database
    open         # Open the slides in the default browser
    runserver    # Run the Django dev server with MONGODB_URI wired up
    startproject # Scaffold the demo project from the local template
```

The private `_uri` recipe (hidden from `--list`) reuses a running
`mongodb-runner` instance tagged `--id demo`, or starts a fresh one,
and prints its URI. `runserver` and `migrate` use `$(just _uri)` to
wire that URI into `MONGODB_URI` — the same env var the generated
`settings.py` reads.

## Demo workflow

```bash
just startproject     # scaffold ./demo from templates/project_template
just migrate          # starts mongodb-runner if needed, runs migrate
just runserver        # http://127.0.0.1:8000/

just dropdb           # wipe the database between runs
just clean            # rm -rvf demo
```

## Requirements

- [`just`](https://github.com/casey/just)
- Python 3.12+ with `django` and `django-mongodb-backend` installed
- [`mongodb-runner`](https://www.npmjs.com/package/mongodb-runner) (Node 20+) for local MongoDB
- [`mongosh`](https://www.mongodb.com/docs/mongodb-shell/) for `dropdb`

## License

MIT.
