defmodule DataDrivenMicroscopyWeb.UserRegistrationLive do
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
        Register for an account
        <:subtitle>
          Already registered?
          <.link navigate={~p"/users/sign_in"} class="font-semibold text-brand hover:underline">
            Sign in
          </.link>
          to your account now.
        </:subtitle>
      </.header>

      <.simple_form
        :let={form}
        id="registration_form"
        for={@form}
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_action}
        action={
          route_helpers(@socket).auth_path(
            @socket.endpoint,
            {@subject_name, :password, :register}
          )
        }
        method="post"
        as={:user}
      >

        <.input field={{form, :name}} type="text" label="Name" required />
        <.input field={{form, :email}} type="email" label="Email" required />
        <.input field={{form, :password}} type="password" label="Password" required />
        <.input field={{form, :password_confirmation}} type="password" label="Confirm Password" required />

        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
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
      |> Form.for_action(:register_with_password,
        api: api,
        as: subject_name |> to_string(),
        id: "#{subject_name}-password-register_with_password" |> slugify(),
        context: %{private: %{ash_authentication?: true}}
      )

    socket =
      socket
      |> assign(
        form: form,
        trigger_action: false,
        subject_name: subject_name
      )
      |> assign_new(:label, fn -> humanize(:register_with_password) end)
      |> assign_new(:inner_block, fn -> nil end)
      |> assign_new(:overrides, fn -> [AshAuthentication.Phoenix.Overrides.Default] end)

    {:ok, socket}
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
  def handle_event("validate", params, socket) do
    params = get_params(params)

    form =
      socket.assigns.form
      |> Form.validate(params, errors: false)

    {:noreply, assign(socket, form: form)}
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
