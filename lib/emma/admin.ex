defmodule Emma.Admin do
  import Ecto.Query, only: [from: 2]
  alias Emma.Admin.{User, Auth}
  alias Emma.Repo

  @spec get_user(id :: integer() | String.t()) :: User.t() | nil
  def get_user(id) when is_integer(id) or is_bitstring(id) do
    Repo.get(User, id)
  end

  @spec list_active_users() :: [User.t()]
  def list_active_users do
    Repo.all(
      from u in User,
        where: is_nil(u.deleted_at)
    )
  end

  @spec create_user(params :: map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create_user(params) when is_map(params) do
    params
    |> User.changeset()
    |> Repo.insert()
  end

  @spec delete_user(user :: User.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def delete_user(%User{deleted_at: nil} = user) do
    user
    |> User.changeset(%{deleted_at: DateTime.utc_now()})
    |> Repo.update()
  end

  def delete_user(%User{} = already_deleted_user), do: {:ok, already_deleted_user}

  @spec authenticate(email :: String.t(), password :: String.t()) ::
          {:ok, User.t()} | {:error, :invalid_credentials}
  def authenticate(email, password) do
    email
    |> Auth.get_user_by_email()
    |> Auth.verify_user(password)
  end

  @spec user_changeset() :: Ecto.Changeset.t()
  def user_changeset, do: User.changeset(%{})

  @spec user_changeset(user :: User.t()) :: Ecto.Changeset.t()
  def user_changeset(params) when is_map(params), do: User.changeset(params)

  @spec sign_in(conn :: Plug.Conn.t(), user :: User.t()) :: Plug.Conn.t()
  def sign_in(%Plug.Conn{} = conn, %User{} = user), do: Auth.Guardian.Plug.sign_in(conn, user)

  @spec sign_out(conn :: Plug.Conn.t()) :: Plug.Conn.t()
  def sign_out(%Plug.Conn{} = conn), do: Auth.Guardian.Plug.sign_out(conn)

  @spec get_token_for_user(user :: User.t()) :: String.t() | nil
  def get_token_for_user(%User{} = user) do
    case Auth.Guardian.encode_and_sign(user, %{}, token_type: :access) do
      {:ok, token, _} -> token
      _ -> nil
    end
  end
end
