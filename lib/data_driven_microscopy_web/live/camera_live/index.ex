defmodule DataDrivenMicroscopyWeb.CameraLive.Index do
  use DataDrivenMicroscopyWeb, :live_view

  alias DataDrivenMicroscopy.Hardware

  @impl true
  def mount(_params, _session, socket) do
    cameras = Hardware.read!(Hardware.Camera)
    {:ok, assign(socket, cameras: cameras, active: nil)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def to_form_error(_changeset, error) do
    field = String.capitalize(Atom.to_string(error.field))
    {error.field, "#{field} #{error.message}", error.vars}
  end

  def apply_action(socket, :index, _params) do
    socket
    |> assign(page_title: "Cameras")
  end

  def apply_action(socket, :new, _params) do
    systems = Hardware.read!(Hardware.System)

    form =
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
    |> assign(form: form, page_title: "New Camera", systems: systems)
  end

  def apply_action(socket, :edit, %{"id" => id}) do
    form =
      Hardware.get!(Hardware.Camera, id: id)
      |> AshPhoenix.Form.for_update(:update,
        api: DataDrivenMicroscopy.Hardware,
        forms: [auto?: true]
      )

    socket
    |> assign(form: form, page_title: "Edit Camera")
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    camera = Hardware.get!(Hardware.Camera, id: id)
    Hardware.destroy!(camera)

    {:noreply, assign(socket, cameras: Hardware.read!(Hardware.Camera))}
  end
end
