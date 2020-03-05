defmodule Emma.Repo.Migrations.DropUniqueIndexInactiveUsers do
  use Ecto.Migration

  def change do
    drop index("users", [:email], name: :inactive_users)
  end
end
