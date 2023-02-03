defmodule DataDrivenMicroscopy.Accounts.Token do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.TokenResource]

  token do
    api DataDrivenMicroscopy.Accounts
  end

  postgres do
    table "tokens"
    repo DataDrivenMicroscopy.Repo
  end
end
