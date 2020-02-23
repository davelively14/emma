defmodule Emma.Admin.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__

  schema "users" do
    field :email, :string
    field :password, :string
    field :deleted_at, :utc_datetime

    timestamps()
  end

  def required_attributes do
    [:email, :password]
  end

  def allowed_attributes do
    [:deleted_at | required_attributes()]
  end

  def changeset(attrs) when is_map(attrs), do: changeset(%User{}, attrs)

  def changeset(%User{} = user \\ %User{}, attrs) do
    user
    |> cast(attrs, allowed_attributes())
    |> validate_required(required_attributes())
    |> validate_format(:email, ~r/.+\@.+\..+/)
    |> validate_length(:password, min: 8, max: 100)
    |> unique_constraint(:email, name: :active_users)
    |> put_pass_hash()
  end

  # Private

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset),
    do: put_change(changeset, :password, Argon2.hash_pwd_salt(password))

  defp put_pass_hash(changeset), do: changeset
end
