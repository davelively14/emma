defmodule Emma.Repo do
  use Ecto.Repo,
    otp_app: :emma,
    adapter: Ecto.Adapters.Postgres
end
