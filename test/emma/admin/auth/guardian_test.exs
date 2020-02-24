defmodule Emma.Admin.Auth.GuardianTest do
  use Emma.DataCase, async: true
  alias Emma.Admin.User
  alias Emma.Admin.Auth
  alias Test.Support.Admin.UserFactory

  describe "subject_for_token/2" do
    test "returns user id as string" do
      user = %User{id: 12}

      assert {:ok, "12"} == Auth.Guardian.subject_for_token(user, %{})
    end

    test "raises function clause error if User not first arg" do
      assert_raise(FunctionClauseError, fn ->
        Auth.Guardian.subject_for_token(%{id: 12}, %{})
      end)
    end
  end

  describe "resource_from_claims/1" do
    test "returns user with id matching value of sub claims" do
      user = UserFactory.insert_user()

      assert {:ok, user} == Auth.Guardian.resource_from_claims(%{"sub" => user.id})
    end

    test "returns correct user even if id is string" do
      user = UserFactory.insert_user()

      assert {:ok, user} == Auth.Guardian.resource_from_claims(%{"sub" => to_string(user.id)})
    end

    test "returns resource_not_found error if user does not exist" do
      assert {:error, :resource_not_found} == Auth.Guardian.resource_from_claims(%{"sub" => -1})
    end
  end
end
