# SPDX-FileCopyrightText: 2025 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0

defmodule NervesLogging do
  @moduledoc """
  NervesLogging forwards log messages from the Linux kernel and syslog to the Elixir logger

  Log messages have the following additional metadata:

  * `:facility` - the facility of the log message
  * `:application` - either `:$kmsg` or `:$syslog`

  See the [Elixir Logger documentation](https://hexdocs.pm/logger/Logger.html) for
  reducing what's logged if the system logs become too noisy. Some examples:

  ```elixir
  # Reduce logging for both syslog and kernel logs
  Logger.put_application_level(:nerves_logging, :error)

  # Adjust logging for kernel logs
  Logger.put_module_level(NervesLogging.KmsgTailer, :error)

  # Adjust logging for syslog logs
  Logger.put_module_level(NervesLogging.SyslogTailer, :error)
  ```
  """

  @typedoc """
  Syslog severity levels

  These map 1:1 to `Logger.level/0` values.
  """
  @type severity() :: Logger.level()

  @typedoc """
  Syslog facilities

  See https://tools.ietf.org/html/rfc5424#section-6.2.1 for the list.
  """
  @type facility() ::
          :kernel
          | :user_level
          | :mail
          | :system
          | :security_authorization
          | :syslogd
          | :line_printer
          | :network_news
          | :UUCP
          | :clock
          | :security_authorization
          | :FTP
          | :NTP
          | :log_audit
          | :log_alert
          | :clock
          | :local0
          | :local1
          | :local2
          | :local3
          | :local4
          | :local5
          | :local6
          | :local7
end
