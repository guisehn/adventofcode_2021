defmodule Program do
  def solve do
    map = input()

    walk({"start", :small}, [], map)
    |> length()
    |> IO.inspect()
  end

  defp input do
    items =
      File.read!("input.txt")
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.split(&1, "-"))

    items = items ++ Enum.map(items, fn [k, v] -> [v, k] end)
    items = Enum.map(items, &add_cave_size/1)

    items
    |> Enum.map(&Enum.at(&1, 0))
    |> Enum.uniq()
    |> Enum.map(fn origin ->
      destinations =
        items
        |> Enum.filter(fn [key, _] -> key == origin end)
        |> Enum.map(fn [_, dest] -> dest end)
        |> Enum.uniq()

      {origin, destinations}
    end)
    |> Enum.into(%{})
    |> Map.delete("end")
  end

  defp add_cave_size([origin, destination]) do
    small? = String.downcase(destination) == destination
    [origin, {destination, if(small?, do: :small, else: :big)}]
  end

  defp walk({"end", _}, path, _map), do: ["end" | path] |> Enum.reverse() |> List.to_tuple()

  defp walk({cave, size}, path, map) do
    if size == :small && cave in path do
      :invalid
    else
      map
      |> next_caves(cave)
      |> Enum.map(&walk(&1, [cave | path], map))
      |> List.flatten()
      |> Enum.filter(& &1 != :invalid)
    end
  end

  defp next_caves(map, cave), do: Map.get(map, cave, [])
end

Program.solve()
