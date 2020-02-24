defmodule Emma.Admin.Auth do
  import Ecto.Query, only: [from: 2]
  alias Emma.Admin.User

  @error_msg {:error, :invalid_credentials}

  def get_user_by_email(email) when is_bitstring(email) do
    Emma.Repo.one(
      from u in User,
        where: u.email == ^email
    )
  end

  def verify_user(%User{password: stored_hash} = user, plain_text_password)
      when is_bitstring(plain_text_password) do
    case Argon2.verify_pass(plain_text_password, stored_hash) do
      true -> {:ok, user}
      false -> @error_msg
    end
  end

  def verify_user(_user, _password) do
    Argon2.no_user_verify()
    @error_msg
  end
end
