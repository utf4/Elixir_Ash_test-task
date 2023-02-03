defmodule DataDrivenMicroscopyWeb.User.TeamLive.LeftNavbar do
  use DataDrivenMicroscopyWeb, :live_component
  use Phoenix.HTML

  @impl true
  def render(assigns) do
    ~H"""
    <div>
  <div class="w-[18rem] flex-initial">
    <!-- Setting button -->
    <.link class="mb-4 flex w-64 items-center space-x-2 rounded-md bg-[#c3cfd9] px-3 py-3 drop-shadow-md hover:bg-white" href={~p"/users/settings"}>
      <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#4b5c6b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-settings">
        <circle cx="12" cy="12" r="3"></circle>
        <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path>
      </svg>
      <span class="px-3 text-lg text-black">User Settings</span>
    </.link>
    <!-- Team button -->
    <.link class="mb-4 flex w-64 items-center space-x-2 rounded-md bg-[#c3cfd9] px-3 py-3 drop-shadow-md hover:bg-white" href={~p"/teams/"}>
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
      <span class="px-3 text-lg text-black">Team</span>
    </.link>
    <!-- System button -->
    <.link class="mb-4 flex w-64 items-center space-x-2 rounded-md bg-[#c3cfd9] px-3 py-3 drop-shadow-md hover:bg-white" href={~p"/systems/"}>
      <svg xmlns="http://www.w3.org/2000/svg" fill="#4b5c6b" viewBox="0 0 24 24" width="32" height="32">
        <g>
          <path fill="none" d="M0 0h24v24H0z" />
          <path d="M5.33 3.271a3.5 3.5 0 0 1 4.472 4.474L20.647 18.59l-2.122 2.121L7.68 9.867a3.5 3.5 0 0 1-4.472-4.474L5.444 7.63a1.5 1.5 0 1 0 2.121-2.121L5.329 3.27zm10.367 1.884l3.182-1.768 1.414 1.414-1.768 3.182-1.768.354-2.12 2.121-1.415-1.414 2.121-2.121.354-1.768zm-7.071 7.778l2.121 2.122-4.95 4.95A1.5 1.5 0 0 1 3.58 17.99l.097-.107 4.95-4.95z" />
        </g>
      </svg>
      <span class="px-3 text-lg text-black">System</span>
    </.link>
  </div>
</div>
    """
  end
end
