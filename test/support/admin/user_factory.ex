defmodule Test.Support.Admin.UserFactory do
  alias Emma.Repo
  alias Emma.Admin.User

  def insert_generic_users(num, opts \\ []) do
    base = Keyword.get(opts, :email, "email@gm.net")
    password = Keyword.get(opts, :password, "asdf1234")

    Enum.map(1..num, fn index ->
      %{email: indexed_email(base, index), password: password}
      |> User.changeset()
      |> Repo.insert!()
    end)
  end

  # Private

  defp indexed_email(email_base, index) do
    [address, domain] = String.split(email_base, "@")
    "#{address}+#{index}@#{domain}"
  end
end
