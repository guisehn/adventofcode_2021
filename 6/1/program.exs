defmodule Program do
  def solve do
    input()
    |> run_days(80)
    |> length()
    |> IO.inspect()
  end

  def run_days(fishes, 0), do: fishes
  def run_days(fishes, days_left), do: run_days(new_day(fishes), days_left - 1)

  defp input do
    File.read!("input.txt")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp new_day(fishes) when is_list(fishes) do
    results = Enum.map(fishes, &new_day/1)

    updated_parents = Enum.map(results, fn {parent, _child} -> parent end)

    new_children =
      results
      |> Enum.map(fn {_parent, child} -> child end)
      |> Enum.filter(& &1)

    updated_parents ++ new_children
  end

  defp new_day(fish_timer) when fish_timer == 0, do: {6, 8}
  defp new_day(fish_timer), do: {fish_timer - 1, nil}
end

Program.solve()
