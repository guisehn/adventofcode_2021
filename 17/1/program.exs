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
  defstruct [:status, :max_y]

  @type t :: %ProbeLaunch{status: :landed | :missed, max_y: integer}

  @spec launch(Probe.velocity, TargetArea.t) :: t
  def launch(velocity, target_area) do
    %Probe{velocity: velocity}
    |> next(target_area)
  end

  defp next(probe, target_area, max_y \\ nil) do
    max_y = max_y(max_y, probe)

    cond do
      TargetArea.within?(probe, target_area) -> %ProbeLaunch{status: :landed, max_y: max_y}
      TargetArea.missed?(probe, target_area) -> %ProbeLaunch{status: :missed, max_y: max_y}
      true -> Probe.move(probe) |> next(target_area, max_y)
    end
  end

  defp max_y(prev, %Probe{position: {_, y}}) when is_nil(prev) or y > prev, do: y
  defp max_y(prev, _), do: prev
end

defmodule Program do
  def solve do
    target_area = input()
    {max_x, max_y} = TargetArea.max_velocity(target_area)

    for x <- 1..max_x do
      for y <- 1..max_y do
        %{velocity: {x, y}, launch: ProbeLaunch.launch({x, y}, target_area)}
      end
    end
    |> List.flatten()
    |> Enum.filter(& &1.launch.status == :landed)
    |> Enum.max_by(& &1.launch.max_y)
    |> then(& &1.launch.max_y)
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
