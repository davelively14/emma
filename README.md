# Emma

[![Build Status](https://travis-ci.org/davelively14/emma.svg?branch=master)](https://travis-ci.org/davelively14/emma) [![Coverage Status](https://coveralls.io/repos/github/davelively14/emma/badge.svg?branch=master)](https://coveralls.io/github/davelively14/emma?branch=master)

<p align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/a/af/Emma_Nutt_circa_1878-1900.jpg">
</p>

[Emma Nutt](https://en.wikipedia.org/wiki/Emma_Nutt), the world's first femail telephone operator.

## Description

TODO

## How to Setup

TODO

## Dev Notes

To run locally:

- Install deps: `mix deps.get`
- Initiallize db: `mix ecto.create`
  - NOTE: dev is setup to utilize a role named `postgres` with the password `postgres`. If you do not already have that role, you can either remove the `username` and `password` configs in `config :emma, Emma.Repo` from `config/dev.exs`, or you can create that role in psql with this command: `CREATE ROLE postgres WITH CREATEDB LOGIN ENCRYPTED PASSWORD 'postgres'`.
- Install assets: `cd assets && npm ci && cd ..`
- Run the server: `mix phx.server`
- Visit `http://localhost:2190`
