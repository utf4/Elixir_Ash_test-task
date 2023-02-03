defmodule DataDrivenMicroscopyWeb.CalibrationLive.Pixelsize.Index do
  use DataDrivenMicroscopyWeb, :live_view

  alias DataDrivenMicroscopy.Hardware

  @impl true
  def mount(_params, _session, socket) do
    calibrations = Hardware.read!(Hardware.Pixelsize)
    {:ok, assign(socket, calibrations: calibrations)}
  end

  def read_objective_name(id) do
    Hardware.get!(Hardware.Objective, id).name
  end

  def read_system_name(objective_id) do
    obj = Hardware.get!(Hardware.Objective, objective_id)
    Hardware.get!(Hardware.System, obj.system_id).name
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :index, _params) do
    socket
    |> assign(page_title: "Camera Calibration")
  end

  def apply_action(socket, :new, _params) do
    objectives = Hardware.read!(Hardware.Objective)

    form =
      Hardware.Pixelsize
      |> AshPhoenix.Form.for_create(:create,
        api: Hardware,
        forms: [
          objective: [
            resource: Hardware.Objective,
            update_action: :update,
            create_action: :create
          ]
        ],
        on_match: :create,
        on_no_match: :create
      )

    socket
    |> assign(form: form, page_title: "New Pixelsize Calibration", objectives: objectives)
  end

  def apply_action(socket, :edit, %{"id" => id}) do
    objectives = Hardware.read!(Hardware.Objective)

    form =
      Hardware.get!(Hardware.Pixelsize, id: id)
      |> AshPhoenix.Form.for_update(:update,
        api: DataDrivenMicroscopy.Hardware
      )

    socket
    |> assign(form: form, page_title: "Edit Pixelsize Calibration", objectives: objectives)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    Hardware.get!(Hardware.Pixelsize, id: id)
    |> Hardware.destroy!()

    {:noreply, assign(socket, calibrations: Hardware.read!(Hardware.Pixelsize))}
  end
end
