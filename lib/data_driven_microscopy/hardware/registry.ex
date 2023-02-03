defmodule DataDrivenMicroscopy.Hardware.Registry do
  use Ash.Registry,
    extensions: [
      Ash.Registry.ResourceValidations
    ]

  entries do
    entry DataDrivenMicroscopy.Hardware.System
    entry DataDrivenMicroscopy.Hardware.Camera
    entry DataDrivenMicroscopy.Hardware.CameraCalibration
    entry DataDrivenMicroscopy.Hardware.Objective
    entry DataDrivenMicroscopy.Hardware.Pixelsize
  end
end
