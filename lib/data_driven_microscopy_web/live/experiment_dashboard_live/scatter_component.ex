defmodule DataDrivenMicroscopyWeb.ExperimentDashboardLive.ScatterComponent do
  use DataDrivenMicroscopyWeb, :live_component
  alias Explorer.DataFrame

  def render(assigns) do
    ~H"""
    <div class={@class}>
      <div class="flex flex-col h-full">
        <div
          id={"#{@id}-scatter"}
          phx-hook="Scatter"
          data-csv={@data |> DataFrame.head(1000) |> DataFrame.dump_csv!()}
          data-columns={@data |> DataFrame.dtypes() |> Jason.encode!()}
          data-xvar={@xvar}
          data-yvar={@yvar}
          class="w-full h-full"
        >
        </div>
        <form phx-change="set-axis" phx-target={@myself}>
          <.input
            errors={[]}
            id="#{@id}-xvar"
            name="xvar"
            type="select"
            options={@data |> DataFrame.names()}
            value={@xvar}
          />
          <.input
            errors={[]}
            id="#{@id}-yvar"
            name="yvar"
            type="select"
            options={@data |> DataFrame.names()}
            value={@yvar}
          />
        </form>
      </div>
    </div>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{data: data} = assigns, socket) do
    [{xvar, _type}, {yvar, _type}] = data |> DataFrame.dtypes() |> Enum.take(2)

    socket =
      socket
      |> assign(assigns)
      |> assign(:xvar, xvar)
      |> assign(:yvar, yvar)

    {:ok, socket}
  end

  def handle_event("set-axis", %{"xvar" => xvar, "yvar" => ybar}, socket) do
    socket =
      socket
      |> assign(:xvar, xvar)
      |> assign(:yvar, ybar)

    {:noreply, socket}
  end
end
