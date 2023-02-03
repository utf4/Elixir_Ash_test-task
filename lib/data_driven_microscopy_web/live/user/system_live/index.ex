defmodule DataDrivenMicroscopyWeb.User.SystemLive.Index do
  use DataDrivenMicroscopyWeb, :live_view

  on_mount {DataDrivenMicroscopyWeb.AuthPlug, :load_assocs_current_user}

  alias DataDrivenMicroscopy.Hardware

  @impl true
  def mount(_params, _session, socket) do
    systems =
      Hardware.read!(Hardware.System)
      |> Enum.map(fn system ->
        Hardware.load!(system, [cameras: [:camera_calibration], objectives: [:pixelsize]])
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

  def get_icon(%DataDrivenMicroscopy.Hardware.CameraCalibration{} = camera_cal) do
    to_days = &((DateTime.diff(DateTime.utc_now(), &1, :second) / 86400) |> trunc())

    case camera_cal.updated_at do
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

  def apply_action(socket, :index, params) do
    camera_cal_form =
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

    pixel_form =
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

    obj_form =
    Hardware.Objective
      |> AshPhoenix.Form.for_create(:create,
        api: Hardware,
        forms: [auto?: true]
      )

    camera_form =
    Hardware.Camera
      |> AshPhoenix.Form.for_create(:create,
        api: DataDrivenMicroscopy.Hardware,
        forms: [
          system: [
            resource: Hardware.System,
            create_action: :create,
            update_action: :update
          ]
        ],
        on_match: :create,
        on_no_match: :create,
        transform_errors: &to_form_error/2
      )

    socket
    |> assign(:camera_cal_form, camera_cal_form)
    |> assign(:obj_form, obj_form)
    |> assign(:pixel_form, pixel_form)
    |> assign(:cam_form, camera_form)
    |> assign(:page_title, "Systems")
  end

  def apply_action(socket, :new, _params) do
    form =
      Hardware.System
      |> AshPhoenix.Form.for_create(:create,
        api: Hardware,
        forms: [auto?: true]
      )

    socket
    |> assign(system_form: form, page_title: "New System")
  end

  defguard is_admin?(socket)
           when socket.assigns.current_user.is_admin == true

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    system = Hardware.get!(Hardware.System, id: id)
    Hardware.destroy!(system)

    {:noreply, assign(socket, systems: Hardware.read!(Hardware.System))}
  end

  @impl true
  def handle_event("trigger-calibration", %{"camera_id" => camera_id}, socket) when is_admin?(socket) do
    key = get_unique_key(camera_id)
    socket =
    if Map.get(socket.assigns, key) do
        assign(socket, key, false)
      else
        assign(socket, key, true)
    end

    {:ok, camera} = Hardware.get!(Hardware.Camera, id: camera_id) |> Hardware.load(:camera_calibration)

    socket =
    if camera.camera_calibration do
      form =
      Hardware.get!(Hardware.CameraCalibration, id: camera.camera_calibration.id)
        |> AshPhoenix.Form.for_update(:update,
          api: Hardware
        )

      assign(socket, camera_cal_form: form)
    else
      socket
    end
    {:noreply, socket}
  end

  def handle_event("trigger-calibration", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("trigger-pixelsize", %{"obj_id" => obj_id}, socket) when is_admin?(socket) do
    key = get_unique_key(obj_id)
    socket =
    if Map.get(socket.assigns, key) do
        assign(socket, key, false)
      else
        assign(socket, key, true)
    end

    {:ok, obj} = Hardware.get!(Hardware.Objective, id: obj_id) |> Hardware.load(:pixelsize)

    socket =
    if obj.pixelsize do
      form =
      Hardware.get!(Hardware.Pixelsize, id: obj.pixelsize.id)
        |> AshPhoenix.Form.for_update(:update,
          api: Hardware
        )

      assign(socket, pixel_form: form)
    else
      socket
    end
    {:noreply, socket}
  end

  def handle_event("trigger-pixelsize", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("trigger-add-component", %{"system_id" => sys_id}, socket) when is_admin?(socket) do
    key = get_unique_key(sys_id)
    socket =
    if Map.get(socket.assigns, key) do
        assign(socket, key, false)
      else
        assign(socket, key, true)
    end
    {:noreply, socket}
  end

  def handle_event("trigger-add-component", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("display-component", %{"atom" => %{"system_component" => sys_comp, "system_id" => sys_id}}, socket) do
    cam_key = get_unique_comp_key("camera", sys_id)
    obj_key = get_unique_comp_key("objective", sys_id)

    socket =
    case sys_comp do
      "camera" ->
        socket
        |> assign(cam_key, true)
        |> assign(obj_key, false)
      "objective" ->
        socket
        |> assign(cam_key, false)
        |> assign(obj_key, true)
      _ ->
        socket
        |> assign(cam_key, false)
        |> assign(obj_key, false)
    end

    {:noreply, socket}
  end

  defp get_unique_key(id) do
    key = String.to_atom("show_obj_" <> "#{id}")
  end

  defp get_unique_comp_key(prefix, id) do
    key = String.to_atom("#{prefix}_" <> "#{id}")
  end

  def format_date(date_time) do
    "#{date_time.year}-#{date_time.month}-#{date_time.day}"
  end

  def to_form_error(_changeset, error) do
    field = String.capitalize(Atom.to_string(error.field))
    {error.field, "#{field} #{error.message}", error.vars}
  end
end
