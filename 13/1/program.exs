defmodule Matrix do
  @type t :: list(list(any))
  @type coord :: {integer, integer}

  @spec new(integer, integer, any) :: t
  def new(max_x, max_y, value) do
    for _y <- 0..max_y do
      for _x <- 0..max_x do
        value
      end
    end
  end

  @spec put(t, coord, integer) :: t
  def put(matrix, {x, y}, value) do
    List.update_at(matrix, y, fn row ->
      List.replace_at(row, x, value)
    end)
  end

  @spec map(t, (integer -> integer)) :: t
  def map(matrix, fun) do
    Enum.map(matrix, fn row ->
      Enum.map(row, fun)
    end)
  end

  @spec with_index(t) :: t
  def with_index(matrix) do
    matrix
    |> Enum.with_index()
    |> Enum.map(fn {row, y} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {value, x} -> {value, {x, y}} end)
    end)
  end

  @spec find_coords(t, (any -> boolean)) :: t
  def find_coords(matrix, fun) do
    matrix
    |> with_index()
    |> List.flatten()
    |> Enum.filter(fn {value, _} -> fun.(value) end)
    |> Enum.map(fn {_, coord} -> coord end)
  end

  @spec count(t, (integer -> boolean)) :: t
  def count(matrix, fun) do
    Enum.reduce(matrix, 0, fn row, acc ->
      acc + Enum.count(row, fun)
    end)
  end

  @spec transpose(t) :: t
  def transpose(matrix) do
    matrix
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end
end

defmodule Paper do
  def fold(paper, {:y, y}) do
    paper
    |> Enum.drop(y + 1)
    |> Enum.reverse()
    |> Matrix.find_coords(& &1 == "#")
    |> Enum.reduce(paper, fn {x, y}, paper -> Matrix.put(paper, {x, y}, "#") end)
    |> Enum.take(y)
  end

  def fold(paper, {:x, x}) do
    paper
    |> Matrix.transpose()
    |> fold({:y, x})
    |> Matrix.transpose()
  end
end

defmodule Program do
  def solve do
    {points, folds} = input()

    max_x = points |> Enum.map(fn {x, _} -> x end) |> Enum.max()
    max_y = points |> Enum.map(fn {_, y} -> y end) |> Enum.max()

    matrix = Matrix.new(max_x, max_y, ".")
    matrix = Enum.reduce(points, matrix, fn {x, y}, matrix -> Matrix.put(matrix, {x, y}, "#") end)

    matrix
    |> Paper.fold(List.first(folds))
    |> Matrix.count(& &1 == "#")
    |> IO.inspect()
  end

  defp input do
    [points, folds] =
      File.read!("input.txt")
      |> String.trim()
      |> String.split("\n\n")

    {parse_input_points(points), parse_input_folds(folds)}
  end

  defp parse_input_points(points) do
    points
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end

  defp parse_input_folds(folds) do
    folds
    |> String.split("\n")
    |> Enum.map(fn line ->
      [_, axis, point] = Regex.run(~r/fold along (x|y)=([0-9]+)/, line)
      {String.to_atom(axis), String.to_integer(point)}
    end)
  end
end

Program.solve()
