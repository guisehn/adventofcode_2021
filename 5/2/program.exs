defmodule Line do
  defstruct [:a, :b]

  @type t :: %Line{a: coord, b: coord}
  @type coord :: {integer, integer}

  @spec new(String.t()) :: t
  def new(input) do
    [a, b] = input |> String.split(" -> ")
    %Line{a: to_coord(a), b: to_coord(b)}
  end

  @spec points(t) :: list(coord)
  def points(%Line{a: {ax, ay}, b: {bx, by}}) when ay == by, do:
    Enum.map(ax..bx, & {&1, ay})

  def points(%Line{a: {ax, ay}, b: {bx, by}}) when ax == bx, do:
    Enum.map(ay..by, & {ax, &1})

  def points(%Line{a: {ax, ay}, b: {bx, by}}) do
    x_points = Enum.map(ax..bx, & {&1, ay})
    y_points = Enum.map(ay..by, & {ax, &1})

    y_points
    |> Enum.with_index()
    |> Enum.map(fn {{_, y}, idx} -> {x_points |> Enum.at(idx) |> elem(0), y} end)
  end

  @spec higher_x(t) :: integer
  def higher_x(%Line{a: {ax, _}, b: {bx, _}}), do: Enum.max([ax, bx])

  @spec higher_y(t) :: integer
  def higher_y(%Line{a: {_, ay}, b: {_, by}}), do: Enum.max([ay, by])

  @spec to_coord(String.t()) :: t
  defp to_coord(str) do
    str
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end
end

defmodule Board do
  @type t :: list(list(integer))

  @spec new(list(Line.t())) :: t
  def new(lines) do
    max_x = lines |> Enum.map(&Line.higher_x/1) |> Enum.max()
    max_y = lines |> Enum.map(&Line.higher_y/1) |> Enum.max()

    for _y <- 0..max_y do
      for _x <- 0..max_x, do: 0
    end
  end

  @spec fill(t, list(Line.t())) :: t
  def fill(board, lines) do
    lines
    |> Enum.map(&Line.points/1)
    |> List.flatten()
    |> Enum.reduce(board, fn {x, y}, board ->
      List.update_at(board, y, &List.update_at(&1, x, fn count -> count + 1 end))
    end)
  end

  @spec count_past_threshold(t, integer) :: integer
  def count_past_threshold(board, threshold) do
    board
    |> List.flatten()
    |> Enum.count(& &1 >= threshold)
  end
end

defmodule Program do
  def solve do
    lines = input() |> Enum.map(&Line.new/1)

    lines
    |> Board.new()
    |> Board.fill(lines)
    |> Board.count_past_threshold(2)
    |> IO.inspect()
  end

  defp input do
    File.read!("input.txt")
    |> String.trim()
    |> String.split("\n")
  end
end

Program.solve()
