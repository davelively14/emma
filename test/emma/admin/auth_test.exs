defmodule Emma.Admin.AuthTest do
  use Emma.DataCase, async: true
  alias Test.Support.Admin.UserFactory
  alias Emma.Admin.Auth

  describe "get_user_by_email/1" do
    test "returns user when provided valid email" do
      user = UserFactory.insert_user()

      assert user == Auth.get_user_by_email(user.email)
    end

    test "returns nil if no user found" do
      assert nil == Auth.get_user_by_email("not an email")
    end
  end

  describe "verify_user/1" do
    test "returns user when provided password is valid" do
      password = "asdf1234"
      user = UserFactory.insert_user(password: password)

      assert {:ok, user} == Auth.verify_user(user, password)
    end

    test "returns error if no User passed" do
      assert {:error, :invalid_credentials} ==
               Auth.verify_user(
                 %{email: "em@gmail.com", password: "asdf2134"},
                 "plain_text_password"
               )
    end

    test "returns error if password not valid" do
      password = "asdf1234"
      user = UserFactory.insert_user(password: password)

      assert {:error, :invalid_credentials} == Auth.verify_user(user, "#{password}+1")
    end
  end
end
