defmodule DataDrivenMicroscopyWeb.Layouts do
  use DataDrivenMicroscopyWeb, :html

  embed_templates "layouts/*"

  @doc """
    
  """
  slot :aside, default: []
  slot :main, required: true
  slot :footer, default: []

  def base(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en" class="h-full">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="csrf-token" content={get_csrf_token()} />
        <.live_title suffix=" · Phoenix Framework">
          <%= assigns[:page_title] || "DataDrivenMicroscopy" %>
        </.live_title>
        <link phx-track-static rel="stylesheet" href={~p"/assets/app.css"} />
        <script defer phx-track-static type="text/javascript" src={~p"/assets/app.js"}>
        </script>
      </head>
      <body class="bg-white antialiased flex flex-col h-full">
        <header class="px-4 sm:px-6 lg:px-8 flex-initial">
          <nav class="fixed top-0 left-0 right-0 z-30 bg-white shadow">
            <div class="container mx-auto px-6 py-3 md:flex md:justify-between md:items-center">
              <div class="flex justify-between items-center">
                <div>
                  <a class="inline-block" href="/">
                    <img class="h-8" src={~p"/images/logo/logo.svg"} />
                  </a>
                </div>
              </div>

              <div class="flex items-center">
                <div class="flex flex-col md:flex-row md:mx-6"></div>
              </div>
              <div class="flex items-center">
                <div class="flex flex-col md:flex-row md:mx-6">
                  <a
                    class="my-1 text-gray-600 hover:text-gray-800 md:mx-4 md:my-0"
                    href="/experiments"
                  >
                    Experiments
                  </a>
                  <a
                    class="my-1 text-gray-600 hover:text-gray-800 md:mx-4 md:my-0"
                    href="/hardware/systems"
                  >
                    Hardware
                  </a>
                  <%= if @current_user do %>
                    <a
                      href="/sign-out"
                      class="my-1 text-gray-600 hover:text-gray-800 md:mx-4 md:my-0"
                    >
                    Sign out
                    </a>
                    <% else %>
                    <a
                      href="/users/sign_in"
                      class="my-1 text-gray-600 hover:text-gray-800 md:mx-4 md:my-0"
                    >
                      Sign In
                      <span aria-hidden="true">&rarr;</span>
                    </a>
                  <% end %>
                </div>
              </div>
            </div>
          </nav>
        </header>

        <aside :if={@aside != []}>
          <%= render_slot(@aside) %>
        </aside>
        <main class="px-4 py-20 sm:px-6 lg:px-8 bg-primaryb-20 w-full flex-auto">
          <div class="mx-auto max-w-[80%]">
            <%= render_slot(@main) %>
          </div>
        </main>

        <footer :if={@footer != []} class="dashed_bg p-4 bg-green-200 rounded-lg shadow flex-initial">
          <%= render_slot(@footer) %>
        </footer>
      </body>
    </html>
    """
  end
end
