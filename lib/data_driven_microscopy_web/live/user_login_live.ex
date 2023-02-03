defmodule DataDrivenMicroscopyWeb.UserLoginLive do
  use DataDrivenMicroscopyWeb, :live_view

  import Slug
  import Phoenix.HTML.Form
  import AshAuthentication.Phoenix.Components.Helpers

  alias AshAuthentication.{Info, Phoenix.Components.Password.Input}
  alias AshPhoenix.Form
  alias DataDrivenMicroscopy.Accounts
  alias DataDrivenMicroscopy.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Sign in to account
        <:subtitle>
          Don't have an account?
          <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
            Sign up
          </.link>
          for an account now.
        </:subtitle>
      </.header>

      <.simple_form
        :let={form}
        id="login_form"
        for={@form}
        action={
          route_helpers(@socket).auth_path(
            @socket.endpoint,
            {@subject_name, :password, :sign_in}
          )
        }
        method="post"
        phx-submit="save"
        phx-trigger-action={@trigger_action}
        phx-change="validate"
      >
        <.input field={{form, :email}} type="email" label="Email" required />
        <.input field={{form, :password}} type="password" label="Password" required />

        <:actions :let={form}>
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>

        <:actions>
          <.button phx-disable-with="Signing in..." class="w-full">
            Sign in <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    api = Info.authentication_api!(User)
    subject_name = Info.authentication_subject_name!(User)

    form =
      User
      |> Form.for_action(:sign_in_with_password,
        api: api,
        as: subject_name |> to_string(),
        id: "#{subject_name}-password-sign_in_with_password" |> slugify(),
        context: %{private: %{ash_authentication?: true}}
      )

    socket =
      socket
      |> assign(
        form: form,
        trigger_action: false,
        subject_name: subject_name
      )
      |> assign_new(:label, fn -> humanize(:sign_in_with_password) end)
      |> assign_new(:inner_block, fn -> nil end)
      |> assign_new(:overrides, fn -> [AshAuthentication.Phoenix.Overrides.Default] end)

    {:ok, socket}
  end

  def handle_event("validate", params, socket) do
    params = get_params(params)

    form =
      socket.assigns.form
      |> Form.validate(params, errors: false)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", params, socket) do
    params = get_params(params)
    form = Form.validate(socket.assigns.form, params)

    socket =
      socket
      |> assign(:form, form)
      |> assign(:trigger_action, form.valid?)

    {:noreply, socket}
  end

  defp get_params(params) do
    param_key =
      User
      |> Info.authentication_subject_name!()
      |> to_string()
      |> slugify()

    Map.get(params, param_key, %{})
  end
end
