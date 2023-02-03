defmodule DataDrivenMicroscopyWeb.UserSettingsLive do
  use DataDrivenMicroscopyWeb, :live_view

  alias DataDrivenMicroscopy.Accounts

  def render(assigns) do
    ~H"""
    <div class="flex items-center border-b-2 px-4">
  <div>
    <img class="h-20" src="https://cdn-icons-png.flaticon.com/128/149/149071.png" alt="User Icon" />
  </div>
  <div class="relative left-1/3 py-6 text-3xl"><%= @current_user.name %></div>
</div>
<div class="flex h-full px-4 pt-12 pb-8">
    <.live_component
      id="left-navbar"
      show
      module={DataDrivenMicroscopyWeb.User.TeamLive.LeftNavbar}
      action={@live_action}
      current_user={@current_user}
    />
<div class="flex flex-col flex-1 w-[70%]">
    <.header>Change Email</.header>
    <.simple_form
      :let={f}
      id="email_form"
      for={@email_form}
      phx-submit="save_email"
      phx-change="validate_email"
    >

      <.input field={{f, :email}} type="email" label="Email" required />

      <.input
        field={{f, :current_password}}
        id="current_password_for_email"
        type="password"
        label="Current password"
        required
      />
      <:actions>
        <.button phx-disable-with="Changing...">Change Email</.button>
      </:actions>
    </.simple_form>

    <.header>Change Password</.header>

    <.simple_form
      :let={f}
      id="password_form"
      for={@password_form}
      method="post"
      phx-change="validate_password"
      phx-submit="save_password"
    >
      <.input field={{f, :email}} type="hidden" />

      <.input
        field={{f, :current_password}}
        type="password"
        label="Current password"
        id="current_password_for_password"
        required
      />
      <.input field={{f, :password}} type="password" label="New password" required />
      <.input field={{f, :password_confirmation}} type="password" label="Confirm new password" />
      <:actions>
        <.button phx-disable-with="Changing...">Change Password</.button>
      </:actions>
    </.simple_form>

    <.header>Change Name</.header>

    <.simple_form
      :let={f}
      id="name_form"
      for={@name_form}
      method="post"
      phx-change="validate_name"
      phx-submit="save_name"
    >
      <.input
        field={{f, :name}}
        type="text"
        label="Name"
        id="name_for_user"
        required
      />
      <:actions>
        <.button phx-disable-with="Changing...">Change Name</.button>
      </:actions>
    </.simple_form>
    </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    socket =
      socket
      |> assign_forms()

    {:ok, socket}
  end

  defp assign_forms(socket) do
    user = socket.assigns.current_user

    name_form_params = %{"name" => user.name}
    email_form_params = %{"email" => user.email}

    email_form =
    AshPhoenix.Form.for_update(
          user,
          :update_email,
          as: "update_email",
          api: Accounts,
          actor: user
        ) |> AshPhoenix.Form.validate(email_form_params, errors: false)

    password_form =
    AshPhoenix.Form.for_update(user, :change_password,
          as: "change_password",
          api: Accounts,
          actor: user
        )

    name_form =
    AshPhoenix.Form.for_update(user, :update_name,
          as: "update_name",
          api: Accounts,
          actor: user
        )
        |> AshPhoenix.Form.validate(name_form_params, errors: false)


    assign(socket, email_form: email_form, password_form: password_form, name_form: name_form)
  end

  @impl true
  def handle_event("validate_email", %{"update_email" => params}, socket) do
    {:noreply,
     assign(socket,
       email_form:
         AshPhoenix.Form.validate(socket.assigns.email_form, params,
           errors: socket.assigns.email_form.submitted_once?
         )
     )}
  end

  @impl true
  def handle_event("save_email", %{"update_email" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.email_form, params: params) do
      {:ok, _result} ->
        {:noreply,
         socket
         |> put_flash(:info, "Email updated successfully")
         |> push_redirect(to: "/users/settings")}

      {:error, email_form} ->
        {:noreply, assign(socket, email_form: email_form)}
    end
  end

  @impl true
  def handle_event("validate_password", %{"change_password" => params}, socket) do
    {:noreply,
     assign(socket,
       password_form:
         AshPhoenix.Form.validate(socket.assigns.password_form, params,
           errors: socket.assigns.password_form.submitted_once?
         )
     )}
  end

  @impl true
  def handle_event("save_password", %{"change_password" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.password_form, params: params) do
      {:ok, _result} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password has been successfully changed.")
         |> push_redirect(to: "/users/settings")}

      {:error, password_form} ->
        {:noreply, assign(socket, password_form: password_form)}
    end
  end

  def handle_event("validate_name", params, socket) do
    {:noreply,
     assign(socket,
       name_form:
         AshPhoenix.Form.validate(socket.assigns.name_form, params,
           errors: socket.assigns.name_form.submitted_once?
         )
     )}
  end

  @impl true
  def handle_event("save_name", params, socket) do
    case AshPhoenix.Form.submit(socket.assigns.name_form, params: params) do
      {:ok, _result} ->
        {:noreply,
         socket
         |> put_flash(:info, "Name updated")
         |> push_redirect(to: "/users/settings")}

      {:error, name_form} ->
        {:noreply, assign(socket, name_form: name_form)}
    end
  end
end
