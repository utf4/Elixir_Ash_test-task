defmodule DataDrivenMicroscopy.Experiments do
  use Ash.Api

  @moduledoc """
  The Experiments context.
  """

  resources do
    registry(DataDrivenMicroscopy.Experiments.Registry)
  end

end
