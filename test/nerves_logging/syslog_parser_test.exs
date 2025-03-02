# SPDX-FileCopyrightText: 2022 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0

defmodule NervesLogging.SyslogParserTest do
  use ExUnit.Case
  doctest NervesLogging.SyslogParser

  alias NervesLogging.SyslogParser

  test "parses syslog messages" do
    assert {:ok, %{facility: :kernel, severity: :emergency, message: "Test Message"}} ==
             SyslogParser.parse("<0>Test Message")

    assert {:ok, %{facility: :user_level, severity: :notice, message: "Test Message"}} ==
             SyslogParser.parse("<13>Test Message")

    assert {:ok, %{facility: :local2, severity: :info, message: "Test Message"}} ==
             SyslogParser.parse("<150>Test Message")

    assert {:ok, %{facility: :local7, severity: :debug, message: "Test Message"}} ==
             SyslogParser.parse("<191>Test Message")

    assert {:ok, %{facility: :kernel, severity: :emergency, message: ""}} ==
             SyslogParser.parse("<0>")
  end

  test "returns an error tuple if it can't parse" do
    assert {:error, :parse_error} == SyslogParser.parse("<beef>non-integer code")
    assert {:error, :parse_error} == SyslogParser.parse("<200>too large code")
    assert {:error, :parse_error} == SyslogParser.parse("<192>too large code")
    assert {:error, :parse_error} == SyslogParser.parse("<-1>negative code")
    assert {:error, :parse_error} == SyslogParser.parse("No syslog code")
  end

  test "decodes priority" do
    assert {:ok, :kernel, :emergency} == SyslogParser.decode_priority(0)
    assert {:ok, :user_level, :notice} == SyslogParser.decode_priority(13)
    assert {:ok, :local2, :info} == SyslogParser.decode_priority(150)
    assert {:ok, :local7, :debug} == SyslogParser.decode_priority(191)
  end
end
