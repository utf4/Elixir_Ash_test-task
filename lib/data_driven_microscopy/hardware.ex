defmodule DataDrivenMicroscopy.Hardware do
  use Ash.Api

  resources do
    registry(DataDrivenMicroscopy.Hardware.Registry)
  end
end
