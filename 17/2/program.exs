defmodule Probe do
  defstruct [position: {0, 0}, velocity: {0, 0}]

  @type t :: %Probe{position: position, velocity: velocity}
  @type position :: {x :: integer, y :: integer}
  @type velocity :: {x_velocity :: integer, y_velocity :: integer}

  @spec move(t) :: t
  def move(%Probe{position: {x, y}, velocity: {vx, vy}}) do
    %Probe{
      position: {x + vx, y + vy},
      velocity: {next_x_velocity(vx), vy - 1}
    }
  end

  defp next_x_velocity(0), do: 0
  defp next_x_velocity(value) when value < 0, do: value + 1
  defp next_x_velocity(value) when value > 0, do: value - 1
end

defmodule TargetArea do
  defstruct [:range]

  @type t :: {x_range :: Range.t(), y_range :: Range.t()}

  @spec within?(Probe.t, t) :: boolean
  def within?(%Probe{position: {x, y}}, %TargetArea{range: {tx, ty}}),
    do: x in tx && y in ty

  @spec missed?(Probe.t, t) :: boolean
  def missed?(%Probe{position: {x, y}}, %TargetArea{range: {tx, ty}}),
    do: x > tx.last || y < ty.first

  def max_velocity(%TargetArea{range: {x, y}}),
    do: {max_from_range(x), max_from_range(y)}

  defp max_from_range(%{first: first, last: last}) do
    [first, last]
    |> Enum.map(&abs/1)
    |> Enum.max()
  end
end

defmodule ProbeLaunch do
  @spec launch(Probe.velocity, TargetArea.t) :: :landed | :missed
  def launch(velocity, target_area) do
    %Probe{velocity: velocity}
    |> next(target_area)
  end

  defp next(probe, target_area) do
    # probe |> IO.inspect()
    cond do
      TargetArea.within?(probe, target_area) -> :landed
      TargetArea.missed?(probe, target_area) -> :missed
      true -> Probe.move(probe) |> next(target_area)
    end
  end
end

defmodule Program do
  def solve do
    target_area = input()
    {max_x, max_y} = TargetArea.max_velocity(target_area)

    for x <- -max_x..max_x do
      for y <- -max_y..max_y do
        %{velocity: {x, y}, status: ProbeLaunch.launch({x, y}, target_area)}
      end
    end
    |> List.flatten()
    |> Enum.filter(& &1.status == :landed)
    |> length()
    |> IO.inspect()
  end

  defp input do
    input = File.read!("input.txt") |> String.trim()
    range = {get_input_range(input, :x), get_input_range(input, :y)}
    %TargetArea{range: range}
  end

  defp get_input_range(input, axis) do
    [_, a, b] = Regex.run(~r/#{axis}=([0-9-]+)..([0-9-]+)/, input)
    String.to_integer(a)..String.to_integer(b)
  end
end

Program.solve()
