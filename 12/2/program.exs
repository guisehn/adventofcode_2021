defmodule Program do
  def solve do
    map = input()

    walk(map, {"start", :small})
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

  defp walk(map, cave, path \\ [], caves_count \\ %{}, visited_small_cave_twice? \\ false)

  defp walk(_, {"end", _}, path, _, _), do:
    ["end" | path] |> Enum.reverse() |> List.to_tuple()

  defp walk(map, {cave, size}, path, caves_count, visited_small_cave_twice?) do
    if size == :small && Map.get(caves_count, cave, 0) >= if(visited_small_cave_twice?, do: 1, else: 2) do
      :invalid
    else
      caves_count = increment_key(caves_count, cave)
      visited_small_cave_twice? = visited_small_cave_twice? || size == :small && Map.get(caves_count, cave, 0) >= 2

      map
      |> next_caves(cave)
      |> Enum.map(&walk(map, &1, [cave | path], caves_count, visited_small_cave_twice?))
      |> List.flatten()
      |> Enum.filter(& &1 != :invalid)
    end
  end

  defp next_caves(map, cave), do: Map.get(map, cave, []) -- [{"start", :small}]

  defp increment_key(map, key, value \\ 1), do:
    Map.update(map, key, value, &(&1 + value))
end

Program.solve()
