defmodule NervesLogging.Application do
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
    # Don't automatically start loggers if they'll fail
    children =
      if File.exists?("/dev/kmsg") do
        [
          NervesLogging.KmsgTailer,
          NervesLogging.SyslogTailer
        ]
      else
        []
      end

    opts = [strategy: :one_for_one, name: NervesLogging.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
