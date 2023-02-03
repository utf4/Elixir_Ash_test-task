defmodule DataDrivenMicroscopy.Repo do
  use AshPostgres.Repo,
    otp_app: :data_driven_microscopy,
    adapter: Ecto.Adapters.Postgres

  def installed_extensions do
    ["citext"]
  end
end
