defmodule Emma.AdminTest do
  use Emma.DataCase, async: true
  alias Test.Support.Admin.UserFactory
  alias Emma.{Admin, Repo}
  alias Emma.Admin.User

  describe "get_user/1" do
    test "returns expected user when provided integer id" do
      user = UserFactory.insert_user()

      assert user == Admin.get_user(user.id)
    end

    test "returns expected user when provided string parsable as id" do
      user = UserFactory.insert_user()

      assert user == Admin.get_user(to_string(user.id))
    end

    test "returns nil if user does not exist" do
      assert nil == Admin.get_user(-1)
    end

    test "raises cast error if non-integer string provided" do
      assert_raise Ecto.Query.CastError, fn ->
        Admin.get_user("1ds")
      end
    end

    test "raises function clause error if non-parsable integer passed as arg" do
      assert_raise FunctionClauseError, fn ->
        Admin.get_user(%{id: 1})
      end
    end
  end

  describe "list_active_users/1" do
    test "returns only active users" do
      [first_user | rest_of_users] = UserFactory.insert_users(4)

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
      user = UserFactory.insert_user()

      assert {:ok, deleted_user} = Admin.delete_user(user)
      assert !is_nil(deleted_user.deleted_at)
    end

    test "is idempotent" do
      user = UserFactory.insert_user()

      {:ok, deleted_user} = Admin.delete_user(user)
      assert {:ok, deleted_user} == Admin.delete_user(deleted_user)
    end

    test "will delete same user multiple times" do
      first_user = UserFactory.insert_user()

      Admin.delete_user(first_user)

      second_user = UserFactory.insert_user()

      assert {:ok, deleted_user} = Admin.delete_user(second_user)
      assert !is_nil(deleted_user.deleted_at)
    end
  end

  describe "authenticate/2" do
    test "returns user when authenticated" do
      password = "asdf1234"
      user = UserFactory.insert_user(password: password)

      assert {:ok, user} == Admin.authenticate(user.email, password)
    end

    test "returns :invalid_credentials error if user does not exist for email" do
      assert {:error, :invalid_credentials} == Admin.authenticate("not an email", "password")
    end

    test "returns :invalid_credentials error if password is incorrect" do
      password = "asdf1234"
      user = UserFactory.insert_user(password: password)

      assert {:error, :invalid_credentials} == Admin.authenticate(user.email, "#{password}+1")
    end
  end
end
