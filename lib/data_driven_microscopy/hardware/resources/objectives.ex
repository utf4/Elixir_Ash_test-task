defmodule DataDrivenMicroscopy.Hardware.Objective do
  use Ash.Resource, data_layer: AshPostgres.DataLayer

  postgres do
    repo(DataDrivenMicroscopy.Repo)
    table "objectives"
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      argument :system_id, :uuid

      change manage_relationship(:system_id, :system, type: :append_and_remove)
    end

    update :update do
      primary? true
      argument :system_id, :uuid

      change manage_relationship(:system_id, :system, type: :append_and_remove)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :magnification, :integer do
      allow_nil? false
    end

    attribute :numerical_aperture, :float

    attribute :working_distance_min, :float

    attribute :working_distance_max, :float

    attribute :immersion_media, :atom do
      constraints one_of: [:air, :oil, :water, :glycerin, :other]
    end

    attribute :objective_type, :atom do
      allow_nil? true

      constraints one_of: [
                    :achromat,
                    :apochromat,
                    :asbestos,
                    :planachromat,
                    :planapochromat,
                    :plan_flour,
                    :super_flour,
                    :super_plan_flour,
                    :cleared_tissue
                  ]
    end
  end

  relationships do
    belongs_to :system, DataDrivenMicroscopy.Hardware.System
    has_one :pixelsize, DataDrivenMicroscopy.Hardware.Pixelsize
  end
end
