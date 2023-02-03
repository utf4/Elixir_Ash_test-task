defmodule DataDrivenMicroscopy.Hardware.CameraCalibration do
  use Ash.Resource, data_layer: AshPostgres.DataLayer

  postgres do
    repo(DataDrivenMicroscopy.Repo)
    table "camera_calibrations"
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      argument :camera_id, :uuid

      change manage_relationship(:camera_id, :camera, type: :append_and_remove)
    end

    update :update do
      primary? true
      argument :camera_id, :uuid

      change manage_relationship(:camera_id, :camera, type: :append_and_remove)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :updated_at, :utc_datetime do
      default &DateTime.utc_now/0
    end

    attribute :a11, :float do
      allow_nil? false
    end

    attribute :a12, :float do
      allow_nil? false
    end

    attribute :a21, :float do
      allow_nil? false
    end

    attribute :a22, :float do
      allow_nil? false
    end
  end

  relationships do
    belongs_to :camera, DataDrivenMicroscopy.Hardware.Camera
  end
end
