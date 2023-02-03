defmodule DataDrivenMicroscopy.Hardware.System do
  use Ash.Resource, data_layer: AshPostgres.DataLayer

  postgres do
    repo(DataDrivenMicroscopy.Repo)
    table "systems"
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      argument :cameras, {:array, :map}
      change manage_relationship(:cameras, type: :direct_control)
    end

    update :update do
      primary? true
      argument :cameras, {:array, :map}
      argument :objectives, {:array, :map}
      change manage_relationship(:cameras, type: :direct_control)
      change manage_relationship(:objectives, type: :direct_control)
    end
  end

  # Attributes are the simple pieces of data that exist on your resource
  attributes do
    uuid_primary_key :id

    # Add a string type attribute called `:name`
    attribute :name, :string do
      allow_nil? false
    end

    attribute :operating_system, :string

    attribute :manufacturer, :string
  end

  relationships do
    has_many :cameras, DataDrivenMicroscopy.Hardware.Camera
    has_many :objectives, DataDrivenMicroscopy.Hardware.Objective
  end
end
