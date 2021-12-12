defmodule Matrix do
  @type t :: list(list(integer))
  @type coord :: {integer, integer}

  @spec coords(t) :: list(coord)
  def coords(matrix) do
    max_y = length(matrix) - 1
    max_x = length(Enum.at(matrix, 0)) - 1

    for y <- 0..max_y do
      for x <- 0..max_x do
        {x, y}
      end
    end
    |> List.flatten()
  end

  @spec adjacent_points(coord) :: list(coord)
  def adjacent_points({x, y}) do
    [
      {x - 1, y - 1},
      {x, y - 1},
      {x + 1, y - 1},
      {x - 1, y},
      {x + 1, y},
      {x - 1, y + 1},
      {x, y + 1},
      {x + 1, y + 1}
    ]
  end

  @spec at(t, coord) :: integer | nil
  def at(_matrix, {x, y}) when x < 0 or y < 0, do: nil
  def at(matrix, {x, y}) do
    row = Enum.at(matrix, y)
    get_col(row, x)
  end

  defp get_col(nil, _x), do: nil
  defp get_col(row, x), do: Enum.at(row, x)

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

  @spec all?(t, (integer -> boolean)) :: boolean
  def all?(matrix, fun) do
    Enum.all?(matrix, fn row ->
      Enum.all?(row, fun)
    end)
  end
end

defmodule Octopus do
  @flash -1

  def next_energy(energy) when energy >= 9, do: @flash
  def next_energy(@flash), do: @flash
  def next_energy(energy), do: energy + 1

  def flashed?(@flash), do: true
  def flashed?(_), do: false

  def unflash(octopuses) do
    Matrix.map(octopuses, fn
      @flash -> 0
      energy -> energy
    end)
  end

  def increase_energy(coords, octopuses) do
    Enum.reduce(coords, octopuses, fn {x, y}, octopuses ->
      octopus = Matrix.at(octopuses, {x, y})

      if octopus == nil || flashed?(octopus) do
        octopuses
      else
        next_energy = octopuses |> Matrix.at({x, y}) |> Octopus.next_energy()

        octopuses
        |> Matrix.put({x, y}, next_energy)
        |> Octopus.maybe_spread_energy({x, y}, next_energy)
      end
    end)
  end

  def maybe_spread_energy(octopuses, coord, @flash) do
    coord
    |> Matrix.adjacent_points()
    |> increase_energy(octopuses)
  end

  def maybe_spread_energy(octopuses, _coord, _), do: octopuses
end

defmodule Program do
  def solve do
    octopuses = input()

    octopuses
    |> rounds()
    |> IO.inspect()
  end

  def rounds(octopuses, rounds \\ 1)

  def rounds(octopuses, rounds) do
    octopuses = next_round(octopuses)

    if Matrix.all?(octopuses, & &1 == 0) do
      rounds
    else
      rounds(octopuses, rounds + 1)
    end
  end

  def next_round(octopuses) do
    octopuses
    |> Matrix.coords()
    |> Octopus.increase_energy(octopuses)
    |> Octopus.unflash()
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
end

Program.solve()
