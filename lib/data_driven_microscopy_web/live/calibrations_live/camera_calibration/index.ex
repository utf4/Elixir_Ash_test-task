defmodule DataDrivenMicroscopyWeb .CalibrationLive.Camera.Index do
  use DataDrivenMicroscopyWeb, :live_view

  alias DataDrivenMicroscopy.Hardware

  @impl true
  def mount(_params, _session, socket) do
    calibrations = Hardware.read!(Hardware.CameraCalibration)
    {:ok, assign(socket, calibrations: calibrations)}
  end

  def read_camera_name(id) do
    Hardware.get!(Hardware.Camera, id).name
  end

  def read_system_name(camera_id) do
    cam = Hardware.get!(Hardware.Camera, camera_id)
    Hardware.get!(Hardware.System, cam.system_id).name
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
    cameras = Hardware.read!(Hardware.Camera)

    form =
      Hardware.CameraCalibration
      |> AshPhoenix.Form.for_create(:create,
        api: Hardware,
        forms: [
          camera: [
            resource: Hardware.Camera,
            create_action: :create,
            update_action: :update
          ]
        ],
        on_match: :create,
        on_no_match: :create
      )

    socket
    |> assign(form: form, page_title: "New Camera Calibration", cameras: cameras)
  end

  def apply_action(socket, :edit, %{"id" => id}) do
    cameras = Hardware.read!(Hardware.Camera)

    form =
      Hardware.get!(Hardware.CameraCalibration, id: id)
      |> AshPhoenix.Form.for_update(:update,
        api: Hardware
      )

    socket
    |> assign(form: form, page_title: "Edit Camera Calibration", cameras: cameras)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    Hardware.get!(Hardware.CameraCalibration, id: id)
    |> Hardware.destroy!()

    {:noreply, assign(socket, calibrations: Hardware.read!(Hardware.CameraCalibration))}
  end
end
