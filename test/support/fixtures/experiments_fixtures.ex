defmodule DataDrivenMicroscopy.ExperimentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `DataDrivenMicroscopy.Experiments` context.
  """

  @doc """
  Generate a experiment.
  """
  def experiment_fixture(attrs \\ %{}) do
    {:ok, experiment} =
      attrs
      |> Enum.into(%{
        description: "some description",
        metadata: %{},
        name: "some name"
      })
      |> DataDrivenMicroscopy.Experiments.create_experiment()

    experiment
  end
end
