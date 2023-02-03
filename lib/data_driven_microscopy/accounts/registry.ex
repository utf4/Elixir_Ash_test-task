defmodule DataDrivenMicroscopy.Accounts.Registry do
  use Ash.Registry, extensions: [Ash.Registry.ResourceValidations]

  entries do
    entry DataDrivenMicroscopy.Accounts.User
    entry DataDrivenMicroscopy.Accounts.Token
    entry DataDrivenMicroscopy.Accounts.Team
    entry DataDrivenMicroscopy.Accounts.TeamJoinedUser
  end
end
