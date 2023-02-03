defmodule DataDrivenMicroscopyWeb.DemoController do
  use DataDrivenMicroscopyWeb, :controller
  alias DataDrivenMicroscopy.DemoClient

  def get_dataset(conn) do
    conn.params["dataset"]
    |> String.downcase()
  end

  def set_dataset(conn, _params) do
    dataset = get_dataset(conn)

    DemoClient.set_dataset(dataset)
    redirect(conn, to: conn.params["path"])
  end

  def start(conn, _params) do
    DemoClient.start()
    redirect(conn, to: conn.params["path"])
  end

  def stop(conn, _params) do
    DemoClient.stop()
    redirect(conn, to: conn.params["path"])
  end

  def resume(conn, _params) do
    DemoClient.resume()
    redirect(conn, to: conn.params["path"])
  end

  def reset(conn, _params) do
    DemoClient.reset()
    redirect(conn, to: conn.params["path"])
  end
end
