defmodule DataDrivenMicroscopyWeb.User.SystemLive.PixelSizeComponent do
use DataDrivenMicroscopyWeb, :live_component
  use Phoenix.HTML

  @impl true

  def render(assigns) do
    ~H"""
    <div>
      <.simple_form :let={f} for={@form} phx-change="validate" phx-target={@myself} phx-submit="save">
        <.input field={{f, :value}} type="float" label="Pixel size (µm)" />
        <.input
          field={{f, :objective_id}}
          type="hidden"
          value={@id}
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
end
