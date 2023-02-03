defmodule DataDrivenMicroscopy.Accounts do
  use Ash.Api

  resources do
    registry DataDrivenMicroscopy.Accounts.Registry
  end
end
