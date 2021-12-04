defmodule Program do
  @typep bit :: 0 | 1
  @typep frequency :: integer

  def solve do
    bit_frequencies =
      input()
      |> transpose()
      |> Enum.map(&Enum.frequencies/1)

    gamma_rate = common_bits(bit_frequencies, :most) |> bin_to_int()
    epsilon_rate = common_bits(bit_frequencies, :least) |> bin_to_int()
    result = gamma_rate * epsilon_rate

    IO.inspect(result)
  end

  @spec input() :: list(list(bit))
  defp input do
    File.read!("input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_input_line/1)
  end

  @spec parse_input_line(String.t()) :: list(bit)
  defp parse_input_line(line) do
    line
    |> String.graphemes()
    |> Enum.map(& &1 |> Integer.parse() |> elem(0))
  end

  @spec transpose(list(list(bit))) :: list(list(bit))
  defp transpose(items) do
    initial_transposed = items |> List.first() |> Enum.map(fn _ -> [] end)
    transpose(items, initial_transposed)
  end

  defp transpose([], transposed), do: Enum.map(transposed, &Enum.reverse/1)

  defp transpose([item | rest], transposed) do
    transposed =
      transposed
      |> Enum.with_index()
      |> Enum.map(fn {column, index} -> [Enum.at(item, index) | column] end)

    transpose(rest, transposed)
  end

  @spec common_bits(list(%{bit => frequency}), :most | :least) :: list(bit)
  defp common_bits(bit_frequencies, type) do
    bit_frequencies
    |> Enum.map(fn bit_frequency ->
      {bit, _frequency} = min_or_max_by(type, bit_frequency, fn {_bit, frequency} -> frequency end)
      bit
    end)
  end

  defp min_or_max_by(:most, list, fun), do: min_or_max_by(:max, list, fun)
  defp min_or_max_by(:least, list, fun), do: min_or_max_by(:min, list, fun)

  defp min_or_max_by(:max, list, fun), do: Enum.max_by(list, fun)
  defp min_or_max_by(:min, list, fun), do: Enum.min_by(list, fun)

  @spec bin_to_int(list(bit)) :: integer
  defp bin_to_int(bits) do
    bits
    |> Enum.join()
    |> Integer.parse(2)
    |> elem(0)
  end
end

Program.solve()
