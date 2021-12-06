defmodule Program do
  @max_timer 8
  @parents_new_timer 6

  def solve do
    input()
    |> fishes_to_map()
    |> run_days(256)
    |> count_population()
    |> IO.inspect()
  end

  defp run_days(fishes, 0), do: fishes
  defp run_days(fishes, days_left), do: run_days(new_day(fishes), days_left - 1)

  defp input do
    File.read!("input.txt")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp fishes_to_map(fishes) do
    fishes_map =
      fishes
      |> Enum.group_by(& &1)
      |> Enum.map(fn {timer, fishes} -> {timer, length(fishes)} end)
      |> Enum.into(%{})

    empty_fishes_map =
      0..@max_timer |> Enum.map(& {&1, 0}) |> Enum.into(%{})

    Map.merge(empty_fishes_map, fishes_map)
  end

  defp new_day(fishes_map) do
    newborns = Map.get(fishes_map, 0)

    fishes_map
    |> Enum.map(fn {timer, _value} ->
      {timer, Map.get(fishes_map, timer + 1)}
    end)
    |> Enum.into(%{})
    |> Map.put(@max_timer, newborns)
    |> Map.update(@parents_new_timer, 0, & &1 + newborns)
  end

  defp count_population(fishes_map) do
    fishes_map
    |> Map.values()
    |> Enum.sum()
  end
end

Program.solve()
