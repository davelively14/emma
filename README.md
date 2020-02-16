# Emma

TODO:

- Add description

## Dev Notes

To run locally:

- Install deps: `mix deps.get`
- Initiallize db: `mix ecto.create`
  - NOTE: dev is setup to utilize a role named `postgres` with the password `postgres`. If you do not already have that role, you can either remove the `username` and `password` configs in `config :emma, Emma.Repo` from `config/dev.exs`, or you can create that role in psql with this command: `CREATE ROLE postgres WITH CREATEDB LOGIN ENCRYPTED PASSWORD 'postgres'`.
- Install assets: `cd assets && npm ci && cd ..`
- Run the server: `mix phx.server`
- Visit `http://localhost:2190`
