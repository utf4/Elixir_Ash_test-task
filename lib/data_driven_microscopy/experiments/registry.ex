defmodule DataDrivenMicroscopy.Experiments.Registry do
  use Ash.Registry,
    extensions: [
      Ash.Registry.ResourceValidations
    ]

  entries do
    entry DataDrivenMicroscopy.Experiments.Experiment
  end
end
