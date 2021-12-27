defmodule Matrix do
  @type t :: list(list(any))
  @type coord :: {integer, integer}

  @spec max_x(t) :: integer
  def max_x([row | _]), do: length(row) - 1

  @spec max_y(t) :: integer
  def max_y(matrix), do: length(matrix) - 1

  @spec coords(t) :: list(coord)
  def coords(matrix) do
    {max_x, max_y} = {max_x(matrix), max_y(matrix)}

    for y <- 0..max_y do
      for x <- 0..max_x do
        {x, y}
      end
    end
    |> List.flatten()
  end

  @spec at(t, coord) :: any | nil
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

defmodule Sea do
  defstruct [:matrix, :coords, :max_x, :max_y]

  @type t :: %Sea{matrix: Matrix.t, coords: list(Matrix.coord), max_x: integer, max_y: integer}
  @type cucumber_type :: :> | :v

  @spec new(Matrix.t) :: t
  def new(matrix), do: %Sea{
    matrix: matrix,
    coords: Matrix.coords(matrix),
    max_x: Matrix.max_x(matrix),
    max_y: Matrix.max_y(matrix)
  }

  @spec move_cucumbers_until_stop(t) :: %{sea: t, step: integer}
  def move_cucumbers_until_stop(sea, step \\ 1) do
    # sea.matrix |> Enum.map(fn row -> row |> Enum.join("") |> IO.puts() end)

    case move_cucumbers(sea) do
      ^sea -> %{sea: sea, step: step}
      new_sea -> move_cucumbers_until_stop(new_sea, step + 1)
    end
  end

  @spec move_cucumbers(t) :: t
  def move_cucumbers(sea) do
    sea
    |> move_cucumbers(:>)
    |> move_cucumbers(:v)
  end

  @spec move_cucumbers(t, cucumber_type) :: t
  def move_cucumbers(%Sea{matrix: matrix, coords: coords} = sea, cucumber_type) do
    matrix =
      coords
      |> Enum.filter(& Matrix.at(matrix, &1) == cucumber_type)
      |> Enum.reduce(matrix, fn {x, y}, new_matrix ->
        next_coord = next_coord(sea, cucumber_type, {x, y})

        case Matrix.at(matrix, next_coord) do
          :. ->
            new_matrix
            |> Matrix.put({x, y}, :.)
            |> Matrix.put(next_coord, cucumber_type)

          _ ->
            new_matrix
        end
      end)

    %{sea | matrix: matrix}
  end

  @spec next_coord(t, cucumber_type, Matrix.coord) :: Matrix.coord
  defp next_coord(%Sea{max_x: max_x}, :>, {x, y}) when x + 1 > max_x, do: {0, y}
  defp next_coord(%Sea{}, :>, {x, y}), do: {x + 1, y}

  defp next_coord(%Sea{max_y: max_y}, :v, {x, y}) when y + 1 > max_y, do: {x, 0}
  defp next_coord(%Sea{}, :v, {x, y}), do: {x, y + 1}
end

defmodule Program do
  def solve do
    input()
    |> Sea.move_cucumbers_until_stop()
    |> Map.get(:step)
    |> IO.inspect()
  end

  defp input do
    File.read!("input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn row -> String.graphemes(row) |> Enum.map(&String.to_atom/1) end)
    |> Sea.new()
  end
end

Program.solve()
