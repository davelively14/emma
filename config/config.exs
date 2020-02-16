# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :emma,
  ecto_repos: [Emma.Repo]

# Configures the endpoint
config :emma, EmmaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "8sExp7NtLS/tvbIKD0R+oYw6Cl/0RFygazd39jhnGN50VC0YqBC4yXQIrmdvys/C",
  render_errors: [view: EmmaWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Emma.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "q5O8kn62"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
