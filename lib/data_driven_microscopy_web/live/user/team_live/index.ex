defmodule DataDrivenMicroscopyWeb.User.TeamLive.Index do
  use DataDrivenMicroscopyWeb, :live_view

  alias DataDrivenMicroscopy.Accounts
  alias DataDrivenMicroscopy.Accounts.Team

  on_mount {DataDrivenMicroscopyWeb.AuthPlug, :load_assocs_current_user}

  @impl true
  def mount(_params, _session, socket) do
    teams =
    if socket.assigns.current_user.is_admin do
      Team
      |> Ash.Query.load(:users)
      |> Accounts.read!()
    else
      socket.assigns.current_user.teams
    end
    {:ok, assign(socket, teams: teams)}
  end

  @impl true
  def handle_event("show-team-details", %{"id" => team_id}, socket) do
    user_id = socket.assigns.current_user.id
    {:noreply, redirect(socket, to: "/teams/#{team_id}")}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :index, _params) do
    assign(socket, page_title: "All Teams")
  end

  def apply_action(socket, :new, _params) do
    form =
      Accounts.Team
      |> AshPhoenix.Form.for_create(:create,
        api: Accounts,
        forms: [auto?: true]
      )

    socket
    |> assign(form: form, page_title: "New Team")
  end

  def apply_action(socket, :edit, %{"id" => id}) do
    form =
      Accounts.get!(Team, id: id)
      |> AshPhoenix.Form.for_update(:update,
        api: Accounts,
        forms: [auto?: true]
      )

    socket
    |> assign(form: form, page_title: "Edit Team")
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    team = Accounts.get!(Team, id: id)
    Accounts.destroy!(team)

    teams =
    if socket.assigns.current_user.is_admin do
      Team
      |> Ash.Query.load(:users)
      |> Accounts.read!()
    else
      socket.assigns.current_user.teams
    end
    {:noreply, assign(socket, teams: teams)}
  end
end
