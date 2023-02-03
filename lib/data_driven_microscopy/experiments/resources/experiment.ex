defmodule DataDrivenMicroscopy.Experiments.Experiment do
  use Ash.Resource, data_layer: AshPostgres.DataLayer

  postgres do
    repo(DataDrivenMicroscopy.Repo)
    table("experiments")
  end

  actions do
    defaults([:create, :read, :update, :destroy])
  end

  attributes do
    uuid_primary_key(:id)

    attribute(:name, :string)
    attribute(:description, :map)
    attribute(:created_at, :utc_datetime)
    attribute(:updated_at, :utc_datetime)
  end
end
