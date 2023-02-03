defmodule Mix.Tasks.Checkup do
  use Mix.Task
  import Mix.Ecto

  @shortdoc "Checks setup"

  @switches []

  @aliases []

  @moduledoc """
  """

  @impl true
  def run(args) do
    repos = parse_repo(args)
    {opts, _} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)

    Enum.each(repos, fn repo ->
      ensure_repo(repo, args)

      ensure_implements(
        repo.__adapter__,
        Ecto.Adapter.Storage,
        "create storage for #{inspect(repo)}"
      )

      opts = repo.config

      database =
        Keyword.fetch!(opts, :database) || raise ":database is nil in repository configuration"

      encoding = if opts[:encoding] == :unspecified, do: nil, else: opts[:encoding] || "UTF8"

      maintenance_database =
        Keyword.get(opts, :maintenance_database, "postgres")

      opts = Keyword.put(opts, :database, maintenance_database)

      check_existence_command = "SELECT FROM pg_database WHERE datname = '#{database}'"

      case run_query(check_existence_command, opts) do
        {:ok, %{num_rows: 1}} -> nil
        _ -> IO.puts("mix ecto.setup")
      end
    end)
  end

  defp run_query(sql, opts) do
    {:ok, _} = Application.ensure_all_started(:ecto_sql)
    {:ok, _} = Application.ensure_all_started(:postgrex)

    opts =
      opts
      |> Keyword.drop([:name, :log, :pool, :pool_size])
      |> Keyword.put(:backoff_type, :stop)
      |> Keyword.put(:max_restarts, 0)

    task = Task.Supervisor.async_nolink(Ecto.Adapters.SQL.StorageSupervisor, fn ->
      {:ok, conn} = Postgrex.start_link(opts)

      value = Postgrex.query(conn, sql, [], opts)
      GenServer.stop(conn)
      value
    end)

    timeout = Keyword.get(opts, :timeout, 15_000)

    case Task.yield(task, timeout) || Task.shutdown(task) do
      {:ok, {:ok, result}} ->
        {:ok, result}
      {:ok, {:error, error}} ->
        {:error, error}
      {:exit, {%{__struct__: struct} = error, _}}
          when struct in [Postgrex.Error, DBConnection.Error] ->
        {:error, error}
      {:exit, reason}  ->
        {:error, RuntimeError.exception(Exception.format_exit(reason))}
      nil ->
        {:error, RuntimeError.exception("command timed out")}
    end
  end
end
