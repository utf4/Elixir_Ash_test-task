defmodule DataDrivenMicroscopyWeb.User.TeamLive.MemberComponent do
  use DataDrivenMicroscopyWeb, :live_component
  use Phoenix.HTML

  alias DataDrivenMicroscopy.Accounts
  alias DataDrivenMicroscopy.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form :let={f} for={@form} phx-change="validate" phx-target={@myself} phx-submit="save">
        <.input
          field={{f, :user_id}}
          type="select"
          label="Users"
          options={@users}
        />
        <.input field={{f, :team_id}} type="hidden" value={@team_id} />
        <:actions>
          <.button phx-disable-with="Saving...">Save</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok, users} = Accounts.read(User)
    users = Enum.map(users, &{&1.name, &1.id})

    socket =
    socket
    |> assign(assigns)
    |> assign(:users, [{"Select a User", nil}] ++ users)

    {:ok, socket}
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
         |> put_flash(:info, "Member added successfully!")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end
end
