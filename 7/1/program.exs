defmodule Program do
  def solve do
    input()
    |> calculate_fuel_consumption()
    |> min_fuel_consumption()
    |> elem(1)
    |> IO.inspect()
  end

  defp input do
    File.read!("input.txt")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp calculate_fuel_consumption(crabs) do
    {min, max} = Enum.min_max(crabs)

    min..max
    |> Enum.map(& {&1, calculate_fuel_consumption(&1, crabs)})
    |> Enum.into(%{})
  end

  defp calculate_fuel_consumption(point, crabs) do
    crabs
    |> Enum.map(& abs(point - &1))
    |> Enum.sum()
  end

  defp min_fuel_consumption(map) do
    Enum.min_by(map, fn {_point, consumption} -> consumption end)
  end
end

Program.solve()
