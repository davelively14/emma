defmodule Emma.Admin do
  import Ecto.Query, only: [from: 2]
  alias Emma.Admin.User
  alias Emma.Repo

  @spec list_active_users() :: [User.t()]
  def list_active_users do
    Repo.all(
      from u in User,
        where: is_nil(u.deleted_at)
    )
  end

  @spec create_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create_user(params) when is_map(params) do
    params
    |> User.changeset()
    |> Repo.insert()
  end

  @spec delete_user(User.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def delete_user(%User{deleted_at: nil} = user) do
    user
    |> User.changeset(%{deleted_at: DateTime.utc_now()})
    |> Repo.update()
  end

  def delete_user(%User{} = already_deleted_user), do: {:ok, already_deleted_user}

  @spec get_user(integer()) :: User.t() | nil
  def get_user(id) when is_integer(id) do
    Repo.get(User, id)
  end
end
