defmodule HeightMap do
  defstruct [:matrix, :max_x, :max_y]

  def new(matrix) do
    max_y = length(matrix) - 1
    max_x = length(Enum.at(matrix, 0)) - 1
    %HeightMap{matrix: matrix, max_x: max_x, max_y: max_y}
  end

  def points(height_map) do
    for y <- 0..height_map.max_y do
      for x <- 0..height_map.max_x do
        {x, y}
      end
    end
    |> List.flatten()
  end

  def min_from_adjacents?(height_map, {x, y}) do
    min_adjacent(height_map, {x, y}) > height_at(height_map, {x, y})
  end

  def min_adjacent(height_map, {x, y}) do
    {x, y}
    |> adjacent_points()
    |> Enum.min_by(&height_at(height_map, &1))
    |> then(&height_at(height_map, &1))
  end

  def adjacent_points({x, y}), do:
    [{x, y - 1}, {x, y + 1}, {x - 1, y}, {x + 1, y}]

  def height_at(_height_map, {x, y}) when x < 0 or y < 0, do: nil
  def height_at(height_map, {x, y}) do
    height_map.matrix |> at(y) |> at(x)
  end

  defp at(nil, _index), do: nil
  defp at(list, index), do: Enum.at(list, index)
end

defmodule BasinFinder do
  @visited :v

  def find(height_map, low_points) do
    low_points
    |> Enum.reduce({height_map, []}, fn {x, y}, {height_map, basins} ->
      {height_map, basin_points} = find_around(height_map, {x, y})
      {height_map, [basin_points | basins]}
    end)
    |> elem(1)
  end

  defp find_around(height_map, {x, y}, basin_points \\ []) do
    if stop?(height_map, {x, y}) do
      {height_map, basin_points}
    else
      height_map = mark_visited(height_map, {x, y})
      basin_points = [{x, y} | basin_points]

      {x, y}
      |> HeightMap.adjacent_points()
      |> Enum.reduce({height_map, basin_points}, fn {x, y}, {height_map, basin_points} ->
        find_around(height_map, {x, y}, basin_points)
      end)
    end
  end

  defp stop?(height_map, {x, y}) do
    HeightMap.height_at(height_map, {x, y}) in [@visited, 9, nil]
  end

  defp mark_visited(height_map, {x, y}) do
    matrix =
      List.update_at(height_map.matrix, y, fn row ->
        List.replace_at(row, x, @visited)
      end)

    Map.put(height_map, :matrix, matrix)
  end
end

defmodule Program do
  def solve do
    height_map = input() |> HeightMap.new()
    points = HeightMap.points(height_map)

    points
    |> Stream.map(& {&1, HeightMap.min_from_adjacents?(height_map, &1)})
    |> Stream.filter(fn {_point, min?} -> min? end)
    |> Enum.map(fn {point, _} -> point end)
    |> then(&BasinFinder.find(height_map, &1))
    |> Enum.map(&length/1)
    |> largest(3)
    |> multiply()
    |> IO.inspect()
  end

  defp input do
    File.read!("input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_input_line/1)
  end

  defp parse_input_line(line) do
    line
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  defp largest(items, amount, acc \\ [])
  defp largest(_items, amount, acc) when length(acc) == amount, do: acc
  defp largest(items, amount, acc) do
    max = Enum.max(items)
    items = List.delete(items, max)
    largest(items, amount, [max | acc])
  end

  defp multiply(items), do: Enum.reduce(items, & &1 * &2)
end

Program.solve()
