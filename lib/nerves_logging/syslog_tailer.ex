# SPDX-FileCopyrightText: 2018 Greg Mefford
# SPDX-FileCopyrightText: 2022 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0

defmodule NervesLogging.SyslogTailer do
  @moduledoc """
  This GenServer routes syslog messages from C-based applications and libraries through
  the Elixir Logger for collection.
  """

  use GenServer

  alias NervesLogging.SyslogParser
  require Logger

  @syslog_path "/dev/log"

  @doc """
  Return current `log_level`
  """
  @spec get_log_level() :: atom()
  def get_log_level() do
    GenServer.call(__MODULE__, :get_log_level)
  end

  @doc """
  Set current `log_level` to one of `Logger.levels()`
  """
  @spec set_log_level(any()) :: :ok | {:error, :bad_level}
  def set_log_level(level) when is_atom(level) do
    if level in Logger.levels() do
      GenServer.cast(__MODULE__, {:set_log_level, level})
    else
      {:error, :bad_level}
    end
  end

  def set_log_level(_) do
    {:error, :bad_level}
  end

  @doc """
  Start the local syslog GenServer.
  """
  @spec start_link(any()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(opts) do
    # Blindly try to remove an old file just in case it exists from a previous run
    _ = File.rm(@syslog_path)

    case :gen_udp.open(0, [:local, :binary, {:active, true}, {:ip, {:local, @syslog_path}}]) do
      {:ok, log_port} ->
        # All processes should be able to log messages
        File.chmod!(@syslog_path, 0o666)
        log_level = Keyword.get(opts, :log_level) |> SyslogParser.validate_log_level()

        {:ok, %{log_port: log_port, log_level: log_level}}

      {:error, reason} ->
        Logger.error("nerves_logger: not starting syslog server due to #{inspect(reason)}")
        :ignore
    end
  end

  @impl GenServer
  def handle_info(
        {:udp, log_port, _, 0, raw_entry},
        state = %{log_port: log_port, log_level: log_level}
      ) do
    case SyslogParser.parse(raw_entry) do
      {:ok, %{facility: facility, severity: severity, message: message}} ->
        if Logger.compare_levels(severity, log_level) in [:gt, :eq] do
          Logger.bare_log(
            severity,
            message,
            application: :"$syslog",
            module: __MODULE__,
            facility: facility
          )
        end

      _ ->
        # This is unlikely to ever happen, but if a message was somehow
        # malformed and we couldn't parse the syslog priority, we should
        # still do a best-effort to pass along the raw data.
        Logger.warning("Malformed syslog report: #{inspect(raw_entry)}")
    end

    {:noreply, state}
  end

  def handle_info(_, state), do: {:noreply, state}

  @impl GenServer
  def handle_call(:get_log_level, _from, state = %{log_level: log_level}) do
    {:reply, log_level, state}
  end

  @impl GenServer
  def handle_cast({:set_log_level, level}, state) do
    {:noreply, Map.put(state, :log_level, level)}
  end
end
