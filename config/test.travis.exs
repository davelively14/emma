use Mix.Config

# Configure your database
config :emma, Emma.Repo,
  database: "emma_test_travis",
  hostname: "localhost",
  port: 5433,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :emma, EmmaWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Reduce complexity to speed up tests. Only use this config in test.
config :argon2_elixir, t_cost: 1, m_cost: 8
