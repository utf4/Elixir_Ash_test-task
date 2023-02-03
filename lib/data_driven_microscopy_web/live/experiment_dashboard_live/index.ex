defmodule DataDrivenMicroscopyWeb.ExperimentDashboardLive.Index do
  use DataDrivenMicroscopyWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    projects = [
      %{
        id: 1,
        name: "Phagocytosis project",
        type: "Transfection efficiency",
        runs: [
          %{title: "Run name", description: "Run description", status: :done}
        ]
      },
      %{id: 2, name: "SARS-COV2", type: "Bead phagocytosis", runs: []}
    ]

    [%{id: active} | _rest] = projects
    {:ok, assign(socket, projects: projects, active: active)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("select-project", %{"id" => project_id}, socket) do
    {:noreply, assign(socket, active: String.to_integer(project_id))}
  end

  defp apply_action(socket, _action, _params) do
    socket
  end
end
