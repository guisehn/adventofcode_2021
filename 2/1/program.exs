defmodule Program do
  @type command :: {action, unit}
  @type action :: :forward | :down | :up
  @type unit :: integer

  @type position :: {horizontal, depth}
  @type horizontal :: unit
  @type depth :: unit

  def solve do
    input()
    |> Enum.reduce({0, 0}, &execute_command/2)
    |> multiply()
    |> IO.inspect()
  end

  @spec input() :: list(command)
  defp input do
    File.read!("input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_input_line/1)
  end

  @spec parse_input_line(String.t()) :: command
  defp parse_input_line(input_line) do
    [command, units] = String.split(input_line, " ")
    command = String.to_atom(command)
    {units, _} = Integer.parse(units)
    {command, units}
  end

  @spec execute_command(command, position) :: position
  defp execute_command({:forward, units}, {horizontal, depth}), do: {horizontal + units, depth}
  defp execute_command({:up, units}, {horizontal, depth}), do: {horizontal, depth - units}
  defp execute_command({:down, units}, {horizontal, depth}), do: {horizontal, depth + units}

  @spec multiply(position) :: unit
  defp multiply({horizontal, depth}), do: horizontal * depth
end

Program.solve()
