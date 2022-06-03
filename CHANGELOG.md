# Changelog

## v0.1.1 - 2022-06-03

* Changes
  * Don't crash when lacking permissions to read logs. Restarting doesn't fix
    the permission issue so this ends up being terminal. The error will be
    logged.

## v0.1.0 - 2022-04-26

Extract system logging from `nerves_runtime`.

* Updates
  * Require Elixir 1.11 and remove all syslog-to-Elixir log level conversion code
    since Elixir accepts all of the syslog levels now.
  * Remove the `:severity` field from log messages since it's redundant now.
    It's unknown if this field was actually used.
