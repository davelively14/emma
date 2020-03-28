defmodule Emma.Admin.Auth.Guardian do
  use Guardian, otp_app: :emma
  require Logger
  alias Emma.{Admin, Admin.User}

  def subject_for_token(%User{id: id}, _claims) do
    {:ok, to_string(id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    case Admin.get_user(id) do
      %User{} = user -> {:ok, user}
      nil -> {:error, :resource_not_found}
    end
  end
end
