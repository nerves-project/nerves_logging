# SPDX-FileCopyrightText: 2022 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0

defmodule NervesLogging.Application do
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
    children = [NervesLogging.KmsgTailer, NervesLogging.SyslogTailer]

    opts = [strategy: :one_for_one, name: NervesLogging.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
