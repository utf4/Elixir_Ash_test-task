defmodule DataDrivenMicroscopyWeb.User.TeamLive.RemoveMemberComponent do
  use DataDrivenMicroscopyWeb, :live_component
  use Phoenix.HTML


  def render(assigns) do
    ~H"""
    <div>
    <div class="modal-header flex flex-shrink-0 items-center justify-center rounded-t-md border-b border-gray-200 p-4">
      <h5 class="text-lg font-medium text-gray-800">Are you sure?</h5>
    </div>
    <.simple_form :let={f} for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
        <.input field={{f, :current_password}} type="password" label="Confirm with password" />
        <div class="modal-footer flex flex-shrink-0 flex-wrap items-center justify-between rounded-b-md border-t border-gray-200 p-4">
        </div>
          <:actions>
            <.link href={"/teams/#{assigns.team_id}"} type="button" class="inline-block rounded bg-orange-600 px-6 py-2.5 text-xs font-medium uppercase leading-tight text-white shadow-md transition duration-150 ease-in-out hover:bg-purple-700 hover:shadow-lg focus:bg-purple-700 focus:shadow-lg focus:outline-none focus:ring-0 active:bg-purple-800 active:shadow-lg">Back</.link>
            <.button class="ml-1 inline-block rounded bg-red-600 px-6 py-2.5 text-xs font-medium uppercase leading-tight text-white shadow-md transition duration-150 ease-in-out hover:bg-blue-700 hover:shadow-lg focus:bg-blue-700 focus:shadow-lg focus:outline-none focus:ring-0 active:bg-blue-800 active:shadow-lg" phx-disable-with="Confirming...">Confirm</.button>
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
      :ok ->
        {:noreply,
         socket
         |> put_flash(:info, "Member removed successfully!")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end
end
