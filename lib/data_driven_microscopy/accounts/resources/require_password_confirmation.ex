defmodule DataDrivenMicroscopy.Accounts.RequirePasswordConfirmation do
  use Ash.Resource.Change

  def change(changeset, opts, %{actor: actor}) do
    Ash.Changeset.before_action(changeset, fn changeset ->
      current_password = Ash.Changeset.get_argument(changeset, opts[:password])
      if valid_password?(current_password, actor.hashed_password) do
        changeset
      else
        Ash.Changeset.add_error(changeset, field: opts[:password], message: "Password is incorrect")
      end
    end)
  end

  def valid_password?(password, hash_password) do
    Bcrypt.verify_pass(password, hash_password)
  end
end
