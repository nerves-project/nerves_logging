# NervesLogging

[![Hex version](https://img.shields.io/hexpm/v/nerves_logging.svg "Hex version")](https://hex.pm/packages/nerves_logging)
[![API docs](https://img.shields.io/hexpm/v/nerves_logging.svg?label=hexdocs "API docs")](https://hexdocs.pm/nerves_logging/NervesLogging.html)
[![CircleCI](https://circleci.com/gh/nerves-project/nerves_logging.svg?style=svg)](https://circleci.com/gh/nerves-project/nerves_logging)
[![REUSE status](https://api.reuse.software/badge/github.com/nerves-project/nerves_logging)](https://api.reuse.software/info/github.com/nerves-project/nerves_logging)

NervesLogging forwards log messages from the Linux kernel and syslog to the
Elixir logger. It's used with Nerves so that all log messages pass through one
place.

Messages logged by NervesLogging copy the "Syslog" severity directly to the
Logger level. This means that if the kernel's level is "Error", the Elixir level
will be `:error`. Since Elixir 1.11 and later have the same log levels as
Syslog, this mapping is 1:1.

The Syslog facility is passed via log metadata.

See the [Elixir Logger documentation](https://hexdocs.pm/logger/Logger.html) for
reducing what's logged if the system logs become too noisy. For example, try
`Logger.put_application_level(:nerves_logging, :error)`.

## Using

NervesLogging can be started with or without configuration. The only available options currently are the `log_level` for `NervesLogging.KmsgTailer` and for `log_level` for `NervesLogging.SyslogTailer`. Both are optional

The options for `log_level` are one of: [:emergency, :alert, :critical, :error, :warning, :notice, :informational, :debug]. Default is `:error`.

Configure with:
```elixir
config :nerves_logging, :syslog,
  log_level: :error

config :nerves_logging, :kmsg,
  log_level: :error
```

Add one of the following to a supervision tree to capture the
logs (note, the configuration options above will NOT be applied when adding to a custom supervison tree like in the code snippets below):

```elixir
    [NervesLogging.KmsgTailer, NervesLogging.SyslogTailer]
```

```elixir
    # add with options
    [{NervesLogging.KmsgTailer, [log_level: :error]}, {NervesLogging.SyslogTailer, [log_level: :error]}]
```

If you're using Nerves, you don't need to do this.
[Nerves.Runtime](https://github.com/nerves-project/nerves_runtime) adds these to
its supervision tree. The configuration options can be applied using this method.

## License

All original source code in this project is licensed under Apache-2.0.

Additionally, this project follows the [REUSE recommendations](https://reuse.software)
and labels so that licensing and copyright are clear at the file level.

Exceptions to Apache-2.0 licensing are:

* Configuration and data files are licensed under CC0-1.0
* Documentation is CC-BY-4.0
