defmodule DataDrivenMicroscopyWeb.PageController do
  use DataDrivenMicroscopyWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: "/experiments")
  end
end
