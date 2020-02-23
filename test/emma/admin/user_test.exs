defmodule Emma.Admin.UserTest do
  use Emma.DataCase, async: true
  alias Emma.Admin.User

  describe "changeset/1" do
    test "returns valid changeset when provided valid attributes" do
      attrs = %{email: "fake@gmailish.com", password: "asdf1234"}

      assert %Ecto.Changeset{valid?: true} = User.changeset(attrs)
    end

    test "encrypts password on changeset creation" do
      attrs = %{email: "fake@gmailish.com", password: "asdf1234"}

      assert %Ecto.Changeset{valid?: true, changes: %{password: encrypted_password}} =
               User.changeset(attrs)

      assert Argon2.verify_pass("asdf1234", encrypted_password)
    end

    test "returns changeset with error if password too short" do
      attrs = %{email: "fake@gmailish.com", password: "1234567"}

      assert %Ecto.Changeset{valid?: false} = changeset = User.changeset(attrs)
      assert %{password: ["should be at least 8 character(s)"]} == errors_on(changeset)
    end

    test "returns changeset with errors if password not included in attributes" do
      attrs = %{email: "fake@gmailish.com"}

      assert %Ecto.Changeset{valid?: false} = changeset = User.changeset(attrs)
      assert %{password: ["can't be blank"]} == errors_on(changeset)
    end

    test "returns changeset with errors if email not included in attributes" do
      attrs = %{password: "asdf1234"}

      assert %Ecto.Changeset{valid?: false} = changeset = User.changeset(attrs)
      assert %{email: ["can't be blank"]} == errors_on(changeset)
    end

    test "returns changeset with errors on insert if email already taken" do
      attrs = %{email: "fake@gmailish.com", password: "asdf1234"}

      attrs
      |> User.changeset()
      |> Repo.insert!()

      assert {:error, %Ecto.Changeset{valid?: false} = changeset} =
               attrs |> User.changeset() |> Repo.insert()

      assert %{email: ["has already been taken"]} == errors_on(changeset)
    end
  end

  describe "changeset/2" do
    test "returns valid changeset with updated fields when provided valid attributes" do
      initial_user = %User{email: "dave@g1.com", password: "1234adsf"}
      new_attrs = %{email: "sarah@g1.com", password: "asdf1234"}

      assert %Ecto.Changeset{valid?: true, changes: changes} =
               User.changeset(initial_user, new_attrs)
    end

    test "applies validations to changes" do
      initial_user = %User{email: "dave@g1.com", password: "1234adsf"}

      assert %Ecto.Changeset{valid?: false} =
               changeset = User.changeset(initial_user, %{email: nil, password: nil})

      assert %{email: ["can't be blank"], password: ["can't be blank"]} == errors_on(changeset)
    end
  end
end
