defmodule DataDrivenMicroscopyWeb.CalibrationLive.Pixelsize.FormComponent do
  use DataDrivenMicroscopyWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form :let={f} for={@form} phx-change="validate" phx-target={@myself} phx-submit="save">
        <.input field={{f, :value}} type="float" label="Pixel size (µm)" />
        <.input
          field={{f, :objective_id}}
          type="select"
          label="Objective"
          options={Enum.map(@objectives, fn s -> {s.name, s.id} end)}
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params, errors: false)
    {:noreply, assign(socket, :form, form)}
  end

  @impl true
  def handle_event("save", _params, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form) do
      {:ok, _result} ->
        {:noreply,
         socket
         |> put_flash(:info, "System updated successfully!")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end

  # In order to use the `add_form` and `remove_form` helpers, you
  # need to make sure that you are validating the form on change
  def handle_event("add_form", %{"path" => path}, socket) do
    form = AshPhoenix.Form.add_form(socket.assigns.form, path)
    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("remove_form", %{"path" => path}, socket) do
    form = AshPhoenix.Form.remove_form(socket.assigns.form, path)
    {:noreply, assign(socket, :form, form)}
  end
end
