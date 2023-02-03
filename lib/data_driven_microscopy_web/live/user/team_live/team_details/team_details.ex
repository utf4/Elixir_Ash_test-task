defmodule DataDrivenMicroscopyWeb.User.TeamLive.TeamDetails do
  use DataDrivenMicroscopyWeb, :live_view
  require Ash.Query

  import DataDrivenMicroscopy.Repo

  alias DataDrivenMicroscopy.Accounts
  alias DataDrivenMicroscopy.Accounts.Team
  alias DataDrivenMicroscopy.Accounts.TeamJoinedUser

  on_mount {DataDrivenMicroscopyWeb.AuthPlug, :load_assocs_current_user}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex h-full px-4 pt-12 pb-8">
    <.live_component
      id="left-navbar"
      show
      module={DataDrivenMicroscopyWeb.User.TeamLive.LeftNavbar}
      current_user={@current_user}
    />
    <div class="flex h-full px-4 pb-8">
      <div class="mr-[2rem] flex-auto">
        <div class="relative">
          <div class="mb-8 border-b-4 border-b-[#335262] text-lg"><%= @team.name %></div>
          <.link class="absolute right-10 top-[-5px]" patch={~p"/teams/#{@team.id}/add_member"}>Add Member</.link>
          <div class="absolute right-0 top-[-5px]">
            <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 256 256">
              <rect width="256" height="256" fill="none" />
              <circle cx="80" cy="168" r="32" fill="none" stroke="#4b5c6b" stroke-linecap="round" stroke-linejoin="round" stroke-width="20" />
              <path d="M32,224a60,60,0,0,1,96,0" fill="none" stroke="#4b5c6b" stroke-linecap="round" stroke-linejoin="round" stroke-width="20" />
              <circle cx="80" cy="64" r="32" fill="none" stroke="#4b5c6b" stroke-linecap="round" stroke-linejoin="round" stroke-width="20" />
              <path d="M32,120a60,60,0,0,1,96,0" fill="none" stroke="#4b5c6b" stroke-linecap="round" stroke-linejoin="round" stroke-width="20" />
              <circle cx="176" cy="168" r="32" fill="none" stroke="#4b5c6b" stroke-linecap="round" stroke-linejoin="round" stroke-width="20" />
              <path d="M128,224a60,60,0,0,1,96,0" fill="none" stroke="#4b5c6b" stroke-linecap="round" stroke-linejoin="round" stroke-width="20" />
              <circle cx="176" cy="64" r="32" fill="none" stroke="#4b5c6b" stroke-linecap="round" stroke-linejoin="round" stroke-width="20" />
              <path d="M128,120a60,60,0,0,1,96,0" fill="none" stroke="#4b5c6b" stroke-linecap="round" stroke-linejoin="round" stroke-width="20" />
            </svg>
          </div>
        </div>
        <div class="px-10">
            <%= for team_member <- @team.users do %>
          <div class="flex items-center">
              <div class="relative mb-4 flex h-24 w-[18rem] items-center justify-center rounded text-center text-lg shadow-[6px_6px_5px_-1px_#c1cdd7]">
                <%= team_member.name %>
                <img class="absolute left-[-2rem] h-24" src="https://cdn-icons-png.flaticon.com/128/149/149071.png" alt="User Icon" />
              </div>
              <%= if @current_user.is_admin do %>
                <div class="mx-5 mb-4">
                  <div phx-click="user-dashboard" class="cursor-pointer mb-1 w-48 rounded py-3 text-center shadow-[3px_3px_3px_-3px_#c1cdd7]">Dashboard</div>
                  <div phx-click="user-settings" class="cursor-pointer w-48 rounded py-3 text-center shadow-[3px_3px_3px_-3px_#c1cdd7]">Change Settings</div>
                </div>
                <div phx-click="remove-member" phx-value-user_id={team_member.id} phx-value-team_id={@team.id} class="cursor-pointer w-48 rounded bg-[#d3455b] py-3 text-center text-lg text-white shadow-[3px_3px_3px_-3px_#c1cdd7]">Remove from team</div>
              <% end %>
          </div>
            <% end %>
        </div>
      </div>
    </div>
    </div>
    <.modal
      :if={@live_action in [:add_member]}
      id="member-modal"
      show
      on_cancel={JS.navigate(~p"/teams/#{assigns.team.id}")}
    >
      <.live_component
        module={DataDrivenMicroscopyWeb.User.TeamLive.MemberComponent}
        id={:new}
        navigate={~p"/teams/#{assigns.team.id}"}
        title={@page_title}
        action={@live_action}
        form={@form}
        team={@team}
        team_id={@team.id}
      />
    </.modal>
    <.modal
      :if={@live_action in [:remove_member]}
      id="remove-member-modal"
      show
      on_cancel={JS.navigate(~p"/teams/#{assigns.team.id}")}
    >
      <.live_component
        :if={@live_action in [:remove_member]}
        module={DataDrivenMicroscopyWeb.User.TeamLive.RemoveMemberComponent}
        id={:new}
        navigate={~p"/teams/#{assigns.team.id}"}
        title={@page_title}
        action={@live_action}
        form={@form}
        team={@team}
        team_id={@team.id}
      />
    </.modal>
    """
  end

  @impl true
  def mount(%{"team_id" => team_id} = params, _session, socket) do
    {:ok, team} =
      Team
      |> Ash.Query.filter(id == ^team_id)
      |> Ash.Query.load(:users)
      |> Accounts.read_one()

    {:ok, assign(socket, team: team)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :index, _params) do
    assign(socket, page_title: "Team Members")
  end

  def apply_action(socket, :add_member, _params) do
    form =
      Accounts.TeamJoinedUser
      |> AshPhoenix.Form.for_create(:create,
        api: Accounts,
        forms: [auto?: true]
      )

    socket
    |> assign(form: form, page_title: "Add Member")
  end

  def apply_action(socket, :remove_member, %{"member_id" => member_id, "team_id" => team_id}) do
    {:ok, team_joined_user} = TeamJoinedUser.get_by_team_and_user(team_id, member_id)

    form =
      team_joined_user
      |> AshPhoenix.Form.for_destroy(:destroy_with_password,
        api: Accounts,
        actor: socket.assigns.current_user,
        forms: [auto?: true]
      )

    socket
    |> assign(form: form, page_title: "Remove Member")
  end

  @impl true
  def handle_event("remove-member", %{"user_id" => user_id, "team_id" => team_id}, socket) do
    {:noreply, push_patch(socket, to: "/teams/#{team_id}/remove_member/#{user_id}")}
  end
end
