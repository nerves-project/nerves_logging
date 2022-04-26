# Changelog

## v0.1.0 - 2022-04-26

Extract system logging from `nerves_runtime`.

* Updates
  * Require Elixir 1.11 and remove all syslog-to-Elixir log level conversion code
    since Elixir accepts all of the syslog levels now.
  * Remove the `:severity` field from log messages since it's redundant now.
    It's unknown if this field was actually used.
