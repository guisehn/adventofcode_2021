defmodule Matrix do
  @type t :: list(list(any))
  @type coord :: {integer, integer}

  @spec pad(t, any, integer) :: t
  def pad(matrix, value, times \\ 1) do
    empty_lines = for _ <- 1..times, do:
      for _ <- 0..max_x(matrix) + times * 2, do: value

    empty_border = for _ <- 1..times, do: value
    matrix = Enum.map(matrix, &(empty_border ++ &1 ++ empty_border))
    empty_lines ++ matrix ++ empty_lines
  end

  @spec max_x(t) :: integer
  def max_x(matrix), do: length(Enum.at(matrix, 0)) - 1

  @spec at(t, coord, any) :: any
  def at(matrix, {x, y}, default) do
    case at(matrix, {x, y}) do
      nil -> default
      value -> value
    end
  end

  @spec at(t, coord) :: any | nil
  def at(_matrix, {x, y}) when x < 0 or y < 0, do: nil
  def at(matrix, {x, y}) do
    row = Enum.at(matrix, y)
    get_col(row, x)
  end

  defp get_col(nil, _x), do: nil
  defp get_col(row, x), do: Enum.at(row, x)

  @spec map(t, ((any, coord) -> any)) :: t
  def map(matrix, fun) do
    matrix
    |> Enum.with_index()
    |> Enum.map(fn {row, y} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {value, x} ->
        fun.(value, {x, y})
      end)
    end)
  end

  @spec count(t, (any -> boolean)) :: t
  def count(matrix, fun) do
    Enum.reduce(matrix, 0, fn row, acc ->
      acc + Enum.count(row, fun)
    end)
  end
end

defmodule Enhancer do
  def enhance(image, enhancement, iteration) do
    outside = get_infinite_surrounding(enhancement, iteration)
    image = Matrix.pad(image, outside)

    image
    |> Matrix.map(fn _, {x, y} ->
      {x, y}
      |> enhancement_pos(image, outside)
      |> then(&Enum.at(enhancement, &1))
    end)
  end

  defp enhancement_pos({x, y}, image, outside) do
    {x, y}
    |> area_of_interest()
    |> Enum.map(&Matrix.at(image, &1, outside))
    |> Enum.map(fn
      "#" -> 1
      "." -> 0
    end)
    |> Enum.join("")
    |> Integer.parse(2)
    |> elem(0)
  end

  defp area_of_interest({x, y}) do
    [
      {x - 1, y - 1},
      {x, y - 1},
      {x + 1, y - 1},
      {x - 1, y},
      {x, y},
      {x + 1, y},
      {x - 1, y + 1},
      {x, y + 1},
      {x + 1, y + 1}
    ]
  end

  # This is the main gotcha of this challenge.
  #
  # The challenge says that the image is infinite, and the surroundings of our
  # area of interest are completely dark (full of `.` pixels).
  #
  # When doing an "enhancement round", we need to take these pixels into account.
  # The index on the enhancement algorithm for these pixels is going to be 0, because
  # `.........` is `000000000`.
  #
  # If in on our enhancement algorithm (the first list of the input), the index 0 is also
  # a `.`, the surroundings will always keep dark, so we don't need to care about it.
  #
  # On the other hand, if index 0 of the enhancement list is `#`, all of the infinite
  # surrounding dark elements will become light elements, thus we'll have infinite lights
  # on the first round.
  #
  # On the second round, we'll need to look at index 255 on the enhancement list for the
  # infinite surrounding light elements, as `#########` translates to `111111111`,
  # which in turn translates to 255. If this element turns out to be dark, all surrounding
  # elements will become dark again, light again on the next round, and so on...
  defp get_infinite_surrounding(["." | _], _), do: "."

  defp get_infinite_surrounding(["#" | _] = enhancement, iteration) do
    if rem(iteration, 2) == 0 do
      "#"
    else
      List.last(enhancement)
    end
  end
end

defmodule Program do
  def solve do
    {enhancement, image} = input()

    image
    |> Enhancer.enhance(enhancement, 1)
    |> Enhancer.enhance(enhancement, 2)
    |> pixels_lit()
    |> IO.inspect()
  end

  defp input do
    [enhancement, image] =
      File.read!("input.txt")
      |> String.trim()
      |> String.split("\n\n")

    enhancement = enhancement |> String.replace("\n", "") |> String.graphemes()
    image = image |> String.split("\n") |> Enum.map(&String.graphemes/1)

    {enhancement, image}
  end

  defp pixels_lit(matrix), do: Matrix.count(matrix, & &1 == "#")
end

Program.solve()
