defmodule DataDrivenMicroscopyWeb.ObjectiveLive.Index do
  use DataDrivenMicroscopyWeb, :live_view

  alias DataDrivenMicroscopy.Hardware
  alias DataDrivenMicroscopy.Hardware.Objective

  @impl true
  def mount(_params, _session, socket) do
    objectives =
      Hardware.read!(Objective)
      |> Enum.sort_by(& &1.name)

    {:ok, assign(socket, :objectives, objectives)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :index, _params) do
    socket
    |> assign(page_title: "Objectives")
  end

  def apply_action(socket, :new, _params) do
    form =
      Objective
      |> AshPhoenix.Form.for_create(:create,
        api: Hardware,
        forms: [auto?: true]
      )

    systems = Hardware.read!(Hardware.System)

    socket
    |> assign(form: form, page_title: "New Objective", systems: systems)
  end

  def apply_action(socket, :edit, %{"id" => id}) do
    systems = Hardware.read!(Hardware.System)

    form =
      Hardware.get!(Objective, id)
      |> AshPhoenix.Form.for_update(:update,
        api: Hardware,
        forms: [auto?: true]
      )

    socket
    |> assign(form: form, page_title: "Edit Objective", systems: systems)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    Hardware.get!(Objective, id: id)
    |> Hardware.destroy!()

    {:noreply, assign(socket, objectives: Hardware.read!(Objective))}
  end
end
