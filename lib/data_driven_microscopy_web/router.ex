defmodule DataDrivenMicroscopyWeb.Router do
  use DataDrivenMicroscopyWeb, :router
  use AshAuthentication.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {DataDrivenMicroscopyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :hardware do
    plug :put_root_layout, {DataDrivenMicroscopyWeb.Layouts, :hardware}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DataDrivenMicroscopyWeb do
    pipe_through :browser

    get "/", PageController, :home
    post "/demo/set_dataset", DemoController, :set_dataset
    post "/demo/start", DemoController, :start
    post "/demo/stop", DemoController, :stop
    post "/demo/reset", DemoController, :reset
    post "/demo/resume", DemoController, :resume
  end

  scope "/", DataDrivenMicroscopyWeb do
    pipe_through :browser
    live "/users/sign_in", UserLoginLive, :new
    live "/users/register", UserRegistrationLive, :new
    live "/users/reset_password", UserForgotPasswordLive, :new
    live "/users/reset_password/:token", UserResetPasswordLive, :edit
    sign_out_route AuthController
    auth_routes_for(DataDrivenMicroscopy.Accounts.User, to: AuthController)
  end

  scope "/admin/experiments", DataDrivenMicroscopyWeb.ExperimentLive do
    pipe_through :browser

    live "/", Index, :index
    live "/new", Index, :new
    live "/:id/edit", Index, :edit

    live "/:id", Show, :show
    live "/:id/show/edit", Show, :edit
  end

  scope "/experiments", DataDrivenMicroscopyWeb.ExperimentDashboardLive do
    pipe_through :browser

    live "/", Index, :index
    live "/:project_id/runs/new", ExperimentSetup, :index
  end

  scope "/hardware", DataDrivenMicroscopyWeb do
    pipe_through [:browser, :hardware]
    live "/systems", SystemLive.Index, :index
    live "/systems/new", SystemLive.Index, :new
    live "/systems/:id/edit", SystemLive.Index, :edit
    live "/systems/:id/report", SystemLive.Index, :get_report

    live "/cameras", CameraLive.Index, :index
    live "/cameras/new", CameraLive.Index, :new
    live "/cameras/:id/edit", CameraLive.Index, :edit

    live "/objectives", ObjectiveLive.Index, :index
    live "/objectives/new", ObjectiveLive.Index, :new
    live "/objectives/:id/edit", ObjectiveLive.Index, :edit

    live "/calibration/camera", CalibrationLive.Camera.Index, :index
    live "/calibration/camera/new", CalibrationLive.Camera.Index, :new
    live "/calibration/camera/:id/edit", CalibrationLive.Camera.Index, :edit

    live "/calibration/pixelsize", CalibrationLive.Pixelsize.Index, :index
    live "/calibration/pixelsize/new", CalibrationLive.Pixelsize.Index, :new
    live "/calibration/pixelsize/:id/edit", CalibrationLive.Pixelsize.Index, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", DataDrivenMicroscopyWeb do
  #   pipe_through :api
  # end

  scope "/", DataDrivenMicroscopyWeb do
    pipe_through [:browser]
    ash_authentication_live_session do
      live "/systems", User.SystemLive.Index, :index
      live "/systems/new", User.SystemLive.Index, :new
      live "/calibration/camera/new", User.SystemLive.Index, :new_calibration
      live "/teams", User.TeamLive.Index, :index
      live "/teams/new", User.TeamLive.Index, :new
      live "/teams/:id/edit", User.TeamLive.Index, :edit
      live "/teams/:team_id", User.TeamLive.TeamDetails, :index
      live "/teams/:team_id/add_member", User.TeamLive.TeamDetails, :add_member
      live "/teams/:team_id/remove_member/:member_id", User.TeamLive.TeamDetails, :remove_member
      live "/users/settings", UserSettingsLive, :edit
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:data_driven_microscopy, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: DataDrivenMicroscopyWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
