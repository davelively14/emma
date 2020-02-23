defmodule Emma.Repo.Migrations.CreateUserTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :password, :string
      add :deleted_at, :utc_datetime

      timestamps()
    end

    create unique_index(:users, [:email], where: "deleted_at is NULL", name: :active_users)
    create unique_index(:users, [:email], where: "deleted_at is NOT NULL", name: :inactive_users)
  end
end
