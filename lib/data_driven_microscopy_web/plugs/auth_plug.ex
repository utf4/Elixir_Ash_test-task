defmodule DataDrivenMicroscopyWeb.AuthPlug do
  import Phoenix.Component
  use DataDrivenMicroscopyWeb, :verified_routes

  def on_mount(:live_user_required, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/users/sign_in")}
    end
  end

  def on_mount(:load_assocs_current_user, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, assign(socket, :current_user, DataDrivenMicroscopy.Accounts.load!(socket.assigns.current_user, [teams: :users]))}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/users/sign_in")}
    end
  end
end
