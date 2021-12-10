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
    [{x, y - 1}, {x, y + 1}, {x - 1, y}, {x + 1, y}]
    |> Enum.min_by(&height_at(height_map, &1))
    |> then(&height_at(height_map, &1))
  end

  def height_at(_height_map, {x, y}) when x < 0 or y < 0, do: nil
  def height_at(height_map, {x, y}) do
    height_map.matrix |> at(y) |> at(x)
  end

  defp at(nil, _index), do: nil
  defp at(list, index), do: Enum.at(list, index)
end

defmodule Program do
  def solve do
    height_map = input() |> HeightMap.new()
    points = HeightMap.points(height_map)

    points
    |> Enum.filter(&HeightMap.min_from_adjacents?(height_map, &1))
    # |> Enum.map(&{&1, HeightMap.height_at(height_map, &1)})
    |> Enum.map(&HeightMap.height_at(height_map, &1))
    |> Enum.map(&risk_score/1)
    |> Enum.sum()
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

  defp risk_score(height), do: height + 1
end

Program.solve()
