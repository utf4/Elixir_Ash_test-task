defmodule DataDrivenMicroscopyWeb.UserForgotPasswordLive do
  use DataDrivenMicroscopyWeb, :live_view
  use AshAuthentication.Phoenix.Overrides.Overridable

  import Slug
  import Phoenix.HTML.Form
  import AshAuthentication.Phoenix.Components.Helpers

  alias AshAuthentication.{Info, Phoenix.Components.Password.Input}
  alias AshPhoenix.Form

  alias Phoenix.LiveView.{Rendered, Socket}
  alias DataDrivenMicroscopy.Accounts
  alias DataDrivenMicroscopy.Accounts.User

  @strategy %AshAuthentication.Strategy.Password{
  identity_field: :email,
  hashed_password_field: :hashed_password,
  hash_provider: AshAuthentication.BcryptProvider,
  confirmation_required?: true,
  password_field: :password,
  password_confirmation_field: :password_confirmation,
  register_action_name: :register_with_password,
  sign_in_action_name: :sign_in_with_password,
  resettable: [
    %AshAuthentication.Strategy.Password.Resettable{
      token_lifetime: 72,
      request_password_reset_action_name: :request_password_reset_with_password,
      password_reset_action_name: :password_reset_with_password,
      sender: {DataDrivenMicroscopy.Senders.SendPasswordResetEmail, []}
    }
  ],
  name: :password,
  provider: :password,
  resource: DataDrivenMicroscopy.Accounts.User
}

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Forgot your password?
        <:subtitle>We'll send a password reset link to your inbox</:subtitle>
      </.header>

      <.simple_form
        :let={form}
        id="reset_password_form"
        for={@form}
        phx-submit="submit"
        phx-change="change"
        action={
          route_helpers(@socket).auth_path(
            @socket.endpoint,
            {@subject_name, @strategy.name, :reset_request}
          )
        }
        method="POST"
      >
        <.input field={{form, :email}} type="email" placeholder="Email" required />
        <:actions>
          <.button phx-disable-with="Sending..." class="w-full">
            Send password reset instructions
          </.button>
        </:actions>
      </.simple_form>
      <p class="text-center mt-4">
        <.link href={~p"/users/register"}>Register</.link>
        |
        <.link href={~p"/users/Sign_in"}>Log in</.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    strategy = @strategy
    form = blank_form(strategy)

    socket =
      socket
      |> assign(strategy: strategy)
      |> assign(form: form, subject_name: Info.authentication_subject_name!(strategy.resource))
      |> assign_new(:label, fn -> :request_password_reset_with_password end)
      |> assign_new(:inner_block, fn -> nil end)
      |> assign_new(:overrides, fn -> [AshAuthentication.Phoenix.Overrides.Default] end)

    {:ok, socket}
  end

  def handle_event("change", params, socket) do
    params = get_params(params, socket.assigns.strategy)

    form =
      socket.assigns.form
      |> Form.validate(params, errors: false)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("submit", params, socket) do
    strategy = socket.assigns.strategy
    params = get_params(params, strategy)

    socket.assigns.form
    |> Form.validate(params)
    |> Form.submit()

    flash = override_for(socket.assigns.overrides, :reset_flash_text)

    socket =
      socket
      |> assign(:form, blank_form(strategy))

    socket =
      if flash do
        socket
        |> put_flash(:info, flash)
      else
        socket
      end

    {:noreply, socket}
  end

  defp get_params(params, strategy) do
    param_key =
      strategy.resource
      |> Info.authentication_subject_name!()
      |> to_string()
      |> slugify()

    Map.get(params, param_key, %{})
  end

  defp blank_form(%{resettable: [resettable]} = strategy) do
    api = Info.authentication_api!(strategy.resource)
    subject_name = Info.authentication_subject_name!(strategy.resource)

    strategy.resource
    |> Form.for_action(resettable.request_password_reset_action_name,
      api: api,
      as: subject_name |> to_string(),
      id:
        "#{subject_name}-#{strategy.name}-#{resettable.request_password_reset_action_name}"
        |> slugify(),
      context: %{strategy: strategy, private: %{ash_authentication?: true}}
    )
  end
end
