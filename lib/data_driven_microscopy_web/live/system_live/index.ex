defmodule DataDrivenMicroscopyWeb.SystemLive.Index do
  use DataDrivenMicroscopyWeb, :live_view

  alias DataDrivenMicroscopy.Hardware

  @impl true
  def mount(_params, _session, socket) do
    systems =
      Hardware.read!(Hardware.System)
      |> Enum.map(fn system ->
        Hardware.load!(system, [:cameras, objectives: [:pixelsize]])
      end)

    {:ok, assign(socket, systems: systems, active: nil)}
  end

  def is_active?(system, id) do
    system.id == id
  end

  # get icon based on the last updated time
  def get_icon(%DataDrivenMicroscopy.Hardware.Pixelsize{} = objective) do
    to_days = &((DateTime.diff(DateTime.utc_now(), &1, :second) / 86400) |> trunc())

    case objective.update_at do
      nil ->
        "Gray"

      t ->
        case to_days.(t) do
          d when d < 7 -> "Green"
          d when d < 24 -> "Yellow"
          d when d > 24 -> "Red"
          _ -> "Gray"
        end
    end
  end

  def get_icon(_) do
    "Gray"
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :index, _params) do
    socket
    |> assign(page_title: "Systems")
  end

  def apply_action(socket, :new, _params) do
    form =
      Hardware.System
      |> AshPhoenix.Form.for_create(:create,
        api: Hardware,
        forms: [auto?: true]
      )

    socket
    |> assign(form: form, page_title: "New System")
  end

  def apply_action(socket, :edit, %{"id" => id}) do
    form =
      Hardware.get!(Hardware.System, id: id)
      |> AshPhoenix.Form.for_update(:update,
        api: Hardware,
        forms: [auto?: true]
      )

    socket
    |> assign(form: form, page_title: "Edit System")
  end

  def apply_action(socket, :get_report, %{"id" => id}) do
    case socket.assigns.active do
      nil ->
        system =
          Hardware.get!(Hardware.System, id: id)
          |> Hardware.load!([:cameras, objectives: [:pixelsize]])

        assign(socket, active_system: system, active: id)

      ^id ->
        assign(socket, active: nil)
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    system = Hardware.get!(Hardware.System, id: id)
    Hardware.destroy!(system)

    {:noreply, assign(socket, systems: Hardware.read!(Hardware.System))}
  end
end
