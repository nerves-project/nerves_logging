# SPDX-FileCopyrightText: 2022 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0

defmodule NervesLogging.Application do
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
    syslog_opts = Application.get_env(:nerves_logging, :syslog, [])
    kmsg_opts = Application.get_env(:nerves_logging, :kmsg, [])

    children = [
      {NervesLogging.KmsgTailer, syslog_opts},
      {NervesLogging.SyslogTailer, kmsg_opts}
    ]

    opts = [strategy: :one_for_one, name: NervesLogging.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
