defmodule DataDrivenMicroscopy.Hardware.Pixelsize do
  use Ash.Resource, data_layer: AshPostgres.DataLayer

  postgres do
    repo(DataDrivenMicroscopy.Repo)
    table "pixelsizes"
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      argument :objective_id, :uuid

      change manage_relationship(:objective_id, :objective, type: :append)
    end

    update :update do
      primary? true
      argument :objective_id, :uuid

      change set_attribute(:update_at, &DateTime.utc_now/0)
      change manage_relationship(:objective_id, :objective, type: :append_and_remove)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :value, :float

    attribute :update_at, :utc_datetime do
      default &DateTime.utc_now/0
    end
  end

  relationships do
    belongs_to :objective, DataDrivenMicroscopy.Hardware.Objective
  end
end
