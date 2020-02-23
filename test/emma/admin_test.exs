defmodule Emma.AdminTest do
  use Emma.DataCase, async: true
  # import Ecto.Query, only: [from: 2]
  alias Emma.Admin
  alias Emma.Admin.User
  alias Emma.Repo

  describe "list_active_users/1" do
    test "returns only active users" do
      [first_user | rest_of_users] = insert_users(4)

      first_user
      |> User.changeset(%{deleted_at: DateTime.utc_now()})
      |> Repo.update!()

      assert Enum.sort(rest_of_users) == Enum.sort(Admin.list_active_users())
    end

    test "returns empty list of no active users" do
      assert [] == Admin.list_active_users()
    end
  end

  describe "create_user/1" do
    test "creates a new user with specified email" do
      assert {:ok, %User{email: "g@good.com"}} =
               Admin.create_user(%{email: "g@good.com", password: "asdf1234"})
    end

    test "returns changeset with errors if another user with same email is active" do
      params = %{email: "g@good.com", password: "asdf1234"}
      params |> User.changeset() |> Repo.insert!()

      assert {:error, %Ecto.Changeset{} = changeset} = Admin.create_user(params)
      assert %{email: ["has already been taken"]} == errors_on(changeset)
    end

    test "creates a new user if another user with email is inactive" do
      params = %{email: "g@good.com", password: "asdf1234"}
      user = params |> User.changeset() |> Repo.insert!()
      user |> User.changeset(%{deleted_at: DateTime.utc_now()}) |> Repo.update!()

      assert {:ok, %User{email: "g@good.com"}} = Admin.create_user(params)
    end
  end

  describe "delete_user/1" do
    test "marks user as deleted" do
      [user] = insert_users(1)

      assert {:ok, deleted_user} = Admin.delete_user(user)
      assert !is_nil(deleted_user.deleted_at)
    end

    test "is idempotent" do
      [user] = insert_users(1)

      {:ok, deleted_user} = Admin.delete_user(user)
      assert {:ok, deleted_user} == Admin.delete_user(deleted_user)
    end
  end

  describe "get_user/1" do
    test "returns expected user" do
      [user] = insert_users(1)

      assert user == Admin.get_user(user.id)
    end

    test "returns nil if user does not exist" do
      assert nil == Admin.get_user(-1)
    end

    test "does not accept integer as string" do
      assert_raise FunctionClauseError, fn ->
        Admin.get_user("1")
      end
    end
  end

  # Private

  defp insert_users(num) do
    Enum.map(1..num, fn index ->
      %{email: "email#{index}@gm.net", password: "asdfqwer#{index}"}
      |> User.changeset()
      |> Repo.insert!()
    end)
  end
end
