defmodule Emma.Admin.UserTest do
  use Emma.DataCase, async: true
  alias Emma.Admin.User

  describe "changeset/1" do
    test "returns valid changeset when provided valid attributes" do
      params = %{email: "fake@gmailish.com", password: "asdf1234"}

      assert %Ecto.Changeset{valid?: true} = User.changeset(params)
    end

    test "encrypts password on changeset creation" do
      params = %{email: "fake@gmailish.com", password: "asdf1234"}

      assert %Ecto.Changeset{valid?: true, changes: %{password: encrypted_password}} =
               User.changeset(params)

      assert Argon2.verify_pass("asdf1234", encrypted_password)
    end

    test "returns changeset with error if password too short" do
      params = %{email: "fake@gmailish.com", password: "1234567"}

      assert %Ecto.Changeset{valid?: false} = changeset = User.changeset(params)
      assert %{password: ["should be at least 8 character(s)"]} == errors_on(changeset)
    end

    test "returns changeset with errors if password not included in attributes" do
      params = %{email: "fake@gmailish.com"}

      assert %Ecto.Changeset{valid?: false} = changeset = User.changeset(params)
      assert %{password: ["can't be blank"]} == errors_on(changeset)
    end

    test "returns changeset with errors if email not included in attributes" do
      params = %{password: "asdf1234"}

      assert %Ecto.Changeset{valid?: false} = changeset = User.changeset(params)
      assert %{email: ["can't be blank"]} == errors_on(changeset)
    end

    test "returns changeset with errors on insert if email already taken" do
      params = %{email: "fake@gmailish.com", password: "asdf1234"}

      params
      |> User.changeset()
      |> Repo.insert!()

      assert {:error, %Ecto.Changeset{valid?: false} = changeset} =
               params |> User.changeset() |> Repo.insert()

      assert %{email: ["has already been taken"]} == errors_on(changeset)
    end
  end

  describe "changeset/2" do
    test "returns valid changeset with updated fields when provided valid attributes" do
      initial_user = %User{email: "dave@g1.com", password: "1234adsf"}
      new_params = %{email: "sarah@g1.com", password: "asdf1234"}

      assert %Ecto.Changeset{valid?: true, changes: changes} =
               User.changeset(initial_user, new_params)
    end

    test "applies validations to changes" do
      initial_user = %User{email: "dave@g1.com", password: "1234adsf"}

      assert %Ecto.Changeset{valid?: false} =
               changeset = User.changeset(initial_user, %{email: nil, password: nil})

      assert %{email: ["can't be blank"], password: ["can't be blank"]} == errors_on(changeset)
    end
  end
end
