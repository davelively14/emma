defmodule Emma.Admin.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :emma,
    error_handler: Emma.Admin.Auth.ErrorHandler,
    module: Emma.Admin.Auth.Guardian

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  plug Guardian.Plug.LoadResource, allow_blank: true
end
