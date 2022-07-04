# NervesLogging

[![CircleCI](https://circleci.com/gh/nerves-project/nerves_logging.svg?style=svg)](https://circleci.com/gh/nerves-project/nerves_logging)
[![Hex version](https://img.shields.io/hexpm/v/nerves_logging.svg "Hex version")](https://hex.pm/packages/nerves_logging)

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

There's no configuration. Add the following to a supervision tree to capture the
logs:

```elixir
    [NervesLogging.KmsgTailer, NervesLogging.SyslogTailer]
```

If you're using Nerves, you don't need to do this.
[Nerves.Runtime](https://github.com/nerves-project/nerves_runtime) adds these to
its supervision tree.

## License

Copyright (C) 2017-22 Nerves Project Authors

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

