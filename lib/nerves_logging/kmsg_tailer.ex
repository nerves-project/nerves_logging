# SPDX-FileCopyrightText: 2018 Greg Mefford
# SPDX-FileCopyrightText: 2022 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0

defmodule NervesLogging.KmsgTailer do
  @moduledoc """
  Collects operating system-level messages from `/proc/kmsg`,
  forwarding them to `Logger` with an appropriate level to match the syslog
  priority parsed out of the message.
  """

  use GenServer

  alias NervesLogging.KmsgParser
  require Logger

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
  Start the kmsg monitoring GenServer.
  """
  @spec start_link(any()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(opts) do
    executable = Application.app_dir(:nerves_logging, ["priv", "kmsg_tailer"])

    port =
      Port.open({:spawn_executable, executable}, [
        {:line, 1024},
        :use_stdio,
        :binary,
        :exit_status
      ])

    log_level = Keyword.get(opts, :log_level) |> NervesLogging.SyslogParser.validate_log_level()

    {:ok, %{port: port, buffer: "", log_level: log_level}}
  end

  @impl GenServer
  def handle_info({port, {:data, {:noeol, fragment}}}, %{port: port, buffer: buffer} = state) do
    {:noreply, %{state | buffer: buffer <> fragment}}
  end

  def handle_info(
        {port, {:data, {:eol, fragment}}},
        %{port: port, buffer: buffer, log_level: log_level} = state
      ) do
    handle_message(buffer <> fragment, log_level)
    {:noreply, %{state | buffer: ""}}
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

  defp handle_message(raw_entry, log_level) do
    case KmsgParser.parse(raw_entry) do
      {:ok, %{facility: facility, severity: severity, message: message}} ->
        if Logger.compare_levels(severity, log_level) in [:gt, :eq] do
          Logger.bare_log(
            severity,
            message,
            application: :"$kmsg",
            module: __MODULE__,
            facility: facility
          )
        end

      _ ->
        # We don't handle continuations and multi-line kmsg logs.

        # It's painful to ignore log messages, but these don't seem
        # to be reported by dmesg and the ones I've seen so far contain
        # redundant information that's primary value is that it's
        # machine parsable (i.e. key=value listings)
        :ok
    end
  end
end
