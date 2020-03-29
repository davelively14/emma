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

  describe "user_changeset/0" do
    test "returns user changeset with no changes" do
      assert %Ecto.Changeset{changes: %{}} = Admin.user_changeset()
    end

    test "returns user changeset that is invalid" do
      assert %Ecto.Changeset{valid?: false} = Admin.user_changeset()
    end
  end

  describe "user_changeset/1" do
    test "returns user changeset with allowed params applied" do
      params = %{"email" => "d@gma.com", "password" => "asdf1234"}

      assert %Ecto.Changeset{changes: changes, valid?: true} = Admin.user_changeset(params)
      assert changes.email == params["email"]
      assert changes.password
    end

    test "raises function clause error if params not map" do
      assert_raise FunctionClauseError, fn ->
        Admin.user_changeset("params")
      end
    end
  end

  describe "sign_in/2" do
    setup :provide_conn

    test "returns conn with guardian authentication included", %{conn: conn} do
      conn
      |> Admin.sign_in(UserFactory.insert_user())
      |> Admin.Auth.Guardian.Plug.authenticated?()
      |> assert()
    end
  end

  describe "sign_out/1" do
    setup :provide_conn

    test "returns conn with guardian authentication removed", %{conn: conn} do
      signed_in_conn = Admin.sign_in(conn, UserFactory.insert_user())
      signed_out_conn = Admin.sign_out(signed_in_conn)

      assert signed_in_conn |> Admin.Auth.Guardian.Plug.authenticated?()
      refute Admin.Auth.Guardian.Plug.authenticated?(signed_out_conn)
    end

    test "will return unauthenticated conn if non-auth conn provided", %{conn: conn} do
      refute conn |> Admin.sign_out() |> Admin.Auth.Guardian.Plug.authenticated?()
    end
  end

  describe "get_token_for_user/1" do
    test "generates and returns guardian access token for a user" do
      token = UserFactory.insert_user() |> Admin.get_token_for_user()

      assert %JOSE.JWT{fields: %{"typ" => "access"}} = JOSE.JWT.peek(token)
    end
  end

  # Setup functions

  defp provide_conn(_) do
    {:ok, %{conn: %Plug.Conn{}}}
  end
end
