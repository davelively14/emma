defmodule Test.Support.Admin.UserFactory do
  alias Emma.Repo
  alias Emma.Admin.User

  def insert_user(opts \\ []) do
    email = Keyword.get(opts, :email, "email@gm.net")
    password = Keyword.get(opts, :password, "asdf1234")

    %{email: email, password: password}
    |> User.changeset()
    |> Repo.insert!()
  end

  def insert_users(num, opts \\ []) do
    base = Keyword.get(opts, :email, "email@gm.net")
    password = Keyword.get(opts, :password, "asdf1234")

    Enum.map(1..num, fn index ->
      insert_user(
        email: indexed_email(base, index),
        password: password
      )
    end)
  end

  # Private

  defp indexed_email(email_base, index) do
    [address, domain] = String.split(email_base, "@")
    "#{address}+#{index}@#{domain}"
  end
end
