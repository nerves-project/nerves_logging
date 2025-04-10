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

NervesLogging adds the following metadata to the log messages:

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

## Using

There's no configuration. If you're using Nerves, you should get this
application by default since it's a dependency of
[nerves_runtime](https://github.com/nerves-project/nerves_runtime).

## License

All original source code in this project is licensed under Apache-2.0.

Additionally, this project follows the [REUSE recommendations](https://reuse.software)
and labels so that licensing and copyright are clear at the file level.

Exceptions to Apache-2.0 licensing are:

* Configuration and data files are licensed under CC0-1.0
* Documentation is CC-BY-4.0
