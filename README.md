# Jobs

A small Phoenix JSON API for submitting a **job**: a set of shell **tasks** that may
depend on one another. A job is validated as a DAG (no duplicate task names, no
missing dependencies, no cycles), its tasks are topologically sorted, and it can be
returned either as JSON or as an executable bash script.

## Requirements

* Elixir `~> 1.15`
* PostgreSQL (connection defaults are in `config/dev.exs` / `config/test.exs`)

## Setup

A `docker-compose.yml` is included to run PostgreSQL locally with credentials
matching `config/dev.exs` / `config/test.exs`. Start it with:

```
docker compose up -d
```

Then run `mix setup` to install dependencies and create/migrate the database.

Start the server with `mix phx.server` (or `iex -S mix phx.server` for a shell).
The API is served at [`localhost:4000`](http://localhost:4000).

## API

All endpoints are under `/api`.

### `POST /api/jobs`

Create a job from a list of tasks. Each task has a `name`, a `command`, and an
optional `requires` list naming other tasks (by name) it depends on.

```
POST /api/jobs
Content-Type: application/json
Accept: application/json

{
  "job": {
    "tasks": [
      { "name": "task-1", "command": "touch /tmp/file1" },
      { "name": "task-2", "command": "cat /tmp/file1", "requires": ["task-3"] },
      { "name": "task-3", "command": "echo 'Hello World!' > /tmp/file1", "requires": ["task-1"] },
      { "name": "task-4", "command": "rm /tmp/file1", "requires": ["task-2", "task-3"] }
    ]
  }
}
```

On success (`201 Created`), the tasks are returned topologically sorted (each task
appears after everything it `requires`):

```json
{
  "id": "1f7fd0e7-76ef-47a4-bb84-c8e09b86914f",
  "tasks": [
    { "name": "task-1", "command": "touch /tmp/file1" },
    { "name": "task-3", "command": "echo 'Hello World!' > /tmp/file1" },
    { "name": "task-2", "command": "cat /tmp/file1" },
    { "name": "task-4", "command": "rm /tmp/file1" }
  ]
}
```

The same request with `Accept: text/x-shellscript` returns the job as a runnable
bash script instead (`201 Created`, `Content-Type: text/x-shellscript`):

```bash
#!/usr/bin/env bash
touch /tmp/file1
echo 'Hello World!' > /tmp/file1
cat /tmp/file1
rm /tmp/file1
```

A job is rejected with `422 Unprocessable Entity` when:

* two tasks share a `name` — `{"errors": {"tasks": ["Task names must be unique"]}}`
* a task `requires` a name that doesn't exist in the job —
  `{"errors": {"tasks": ["Some tasks have missing dependencies"]}}`
* the `requires` graph contains a cycle —
  `{"errors": {"tasks": ["Tasks have circular dependencies"]}}`

### `GET /api/jobs`

Lists every job (grouped from persisted tasks by their shared job id), same shape
as a single job's `tasks`/`id`.

### `GET /api/jobs/:id`

Fetches a single job by id.

## Development

* `mix test` — run the test suite (creates/migrates the test database first)
* `mix credo` — static code analysis
* `mix dialyzer` — type-checking via Dialyzer (builds a PLT under `priv/plts/` on
  first run, which can take a few minutes)
* `mix precommit` — compile with warnings as errors, drop unused deps, format, and
  test; run this before committing

## Learn more about Phoenix

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
