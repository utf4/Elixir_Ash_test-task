defmodule DataDrivenMicroscopyWeb.ObjectiveLive.FormComponent do
  use DataDrivenMicroscopyWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form :let={f} for={@form} phx-change="validate" phx-target={@myself} phx-submit="save">
        <.input field={{f, :name}} type="text" label="Name" />
        <.input field={{f, :magnification}} type="number" label="Magnification" />
        <.input field={{f, :numerical_aperture}} type="number" label="Numerical Aperture" />
        <.input field={{f, :working_distance_min}} type="number" label="Working Distance Min" />
        <.input field={{f, :working_distance_max}} type="number" label="Working Distance Max" />
        <.input
          field={{f, :immersion_media}}
          type="select"
          label="Immersion Media"
          options={[
            {"Air", :air},
            {"Oil", :oil},
            {"Water", :water},
            {"Glycerin", :glycerin},
            {"Other", :other}
          ]}
        />

        <.input
          field={{f, :objective_type}}
          type="select"
          label="Type"
          options={[
            {"Achromat", :achromat},
            {"Apochromat", :apochromat},
            {"Asbestos", :asbestos},
            {"Plan Achromat", :planachromat},
            {"Plan Apochromat", :planapochromat},
            {"Plan flour", :plan_flour},
            {"Super flour", :super_flour},
            {"Super plan flour", :super_plan_flour},
            {"Cleared tissue", :cleared_tissue},
            {"Other", :other}
          ]}
        />

        <.input
          field={{f, :system_id}}
          type="select"
          label="Installed on system"
          options={Enum.map(@systems, fn s -> {s.name, s.id} end)}
        />

        <:actions>
          <.button phx-diable-with="Saving..">Save</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params, errors: false)
    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("save", _params, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form) do
      {:ok, _result} ->
        {:noreply,
         socket
         |> put_flash(:info, "System updated successfully!")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end
end
