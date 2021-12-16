defmodule Matrix do
  @type t :: list(list(any))
  @type coord :: {integer, integer}

  @spec last_coord(t) :: coord
  def last_coord(matrix) do
    max_y = length(matrix) - 1
    max_x = length(Enum.at(matrix, 0)) - 1
    {max_x, max_y}
  end

  @spec adjacent_coords(t, coord) :: list(coord)
  def adjacent_coords(matrix, {x, y}) do
    [{x, y - 1}, {x, y + 1}, {x - 1, y}, {x + 1, y}]
    |> Enum.reject(&at(matrix, &1) == nil)
  end

  @spec at(t, coord) :: integer | nil
  def at(_matrix, {x, y}) when x < 0 or y < 0, do: nil
  def at(matrix, {x, y}) do
    row = Enum.at(matrix, y)
    get_col(row, x)
  end

  defp get_col(nil, _x), do: nil
  defp get_col(row, x), do: Enum.at(row, x)

  @spec put(t, coord, any) :: t
  def put(matrix, {x, y}, value) do
    List.update_at(matrix, y, fn row ->
      List.replace_at(row, x, value)
    end)
  end
end

defmodule PathFinder do
  @typep path_node :: %{
    coord: Matrix.coord(),
    parent: path_node | nil,
    cost: integer
  }

  @typep pathfind_state :: %{
    destination: Matrix.coord(),
    open: list(path_node),
    found: found_coords
  }

  @typep found_coords :: MapSet.t(Matrix.coord())

  @initial_node %{coord: {0, 0}, parent: nil, cost: 0}

  @spec find(Matrix.t()) :: {integer, list(Matrix.coord())}
  def find(cave) do
    destination = Matrix.last_coord(cave)
    initial_state = %{destination: destination, open: [], found: MapSet.new()}
    last_node = cave |> find(@initial_node, initial_state)
    {last_node.cost, nodes_to_path(last_node)}
  end

  @spec find(Matrix.t(), path_node, pathfind_state) :: path_node
  defp find(_, %{coord: coord} = node, %{destination: destination}) when coord == destination do
    node
  end

  defp find(cave, node, %{found: found, open: open} = state) do
    adjacent_nodes = adjacent_nodes(node, found, cave)
    found = mark_found_coords(found, [node | adjacent_nodes])

    open = open
      |> List.delete(node)
      |> Kernel.++(adjacent_nodes)

    next = Enum.min_by(open, & &1.cost)
    find(cave, next, Map.merge(state, %{found: found, open: open}))
  end

  @spec adjacent_nodes(path_node, found_coords, Matrix.t()) :: list(path_node)
  defp adjacent_nodes(node, found, cave) do
    cave
    |> Matrix.adjacent_coords(node.coord)
    |> Enum.reject(&MapSet.member?(found, &1))
    |> Enum.map(fn {x, y} ->
      cost = node.cost + Matrix.at(cave, {x, y})
      %{coord: {x, y}, parent: node, cost: cost}
    end)
  end

  @spec mark_found_coords(found_coords, list(path_node)) :: found_coords
  defp mark_found_coords(found, nodes) do
    coords = Enum.map(nodes, & &1.coord)
    MapSet.union(found, MapSet.new(coords))
  end

  @spec nodes_to_path(path_node) :: list(Matrix.coord())
  defp nodes_to_path(node, path \\ [])
  defp nodes_to_path(%{coord: coord, parent: nil}, path), do: [coord | path]
  defp nodes_to_path(%{coord: coord, parent: parent}, path) do
    nodes_to_path(parent, [coord | path])
  end
end

defmodule Program do
  def solve do
    cave = input()
    {cost, path} = PathFinder.find(cave)
    print_path(cave, path)
    cost |> IO.inspect()
  end

  defp input do
    File.read!("input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp print_path(cave, path, path_color \\ IO.ANSI.reset(), rest_color \\ IO.ANSI.light_black()) do
    IO.write(rest_color)

    path
    |> Enum.reduce(cave, fn {x, y}, cave ->
      Matrix.put(cave, {x, y}, "#{path_color}#{Matrix.at(cave, {x, y})}#{rest_color}")
    end)
    |> Enum.map(fn row -> row |> Enum.join("") |> IO.puts() end)

    IO.puts(IO.ANSI.reset())
  end
end

Program.solve()
