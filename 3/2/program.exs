defmodule Program do
  @typep bit :: 0 | 1
  @typep frequency :: integer

  def solve do
    bit_matrix = input()
    o2_gen_rating = bit_matrix |> o2_gen_rating() |> bin_to_int()
    co2_scrubber_rating = bit_matrix |> co2_scrubber_rating() |> bin_to_int()
    result = o2_gen_rating * co2_scrubber_rating
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

  @spec o2_gen_rating(list(list(bit))) :: list(bit)
  defp o2_gen_rating(bit_matix, position \\ 0)

  defp o2_gen_rating([bits], _), do: bits

  defp o2_gen_rating(bit_matrix, position) do
    most_frequent_bit =
      bit_matrix
      |> bit_frequencies()
      |> Enum.at(position)
      |> most_frequent()

    bit_matrix
    |> Enum.filter(&(Enum.at(&1, position) == most_frequent_bit))
    |> o2_gen_rating(position + 1)
  end

  @spec co2_scrubber_rating(list(list(bit))) :: list(bit)
  defp co2_scrubber_rating(bit_matix, position \\ 0)

  defp co2_scrubber_rating([bits], _), do: bits

  defp co2_scrubber_rating(bit_matrix, position) do
    least_frequent_bit =
      bit_matrix
      |> bit_frequencies()
      |> Enum.at(position)
      |> least_frequent()

    bit_matrix
    |> Enum.filter(&(Enum.at(&1, position) == least_frequent_bit))
    |> co2_scrubber_rating(position + 1)
  end

  @spec bit_frequencies(list(list(bit))) :: %{bit => frequency}
  defp bit_frequencies(bit_matrix) do
    bit_matrix
    |> transpose()
    |> Enum.map(&Enum.frequencies/1)
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

  @spec most_frequent(%{bit => frequency}) :: bit
  defp most_frequent(bit_frequency) do
    if identical_frequency?(bit_frequency) do
      1
    else
      Enum.max_by(bit_frequency, &get_frequency/1) |> elem(0)
    end
  end

  @spec least_frequent(%{bit => frequency}) :: bit
  defp least_frequent(bit_frequency) do
    if identical_frequency?(bit_frequency) do
      0
    else
      Enum.min_by(bit_frequency, &get_frequency/1) |> elem(0)
    end
  end

  @spec identical_frequency?(%{bit => frequency}) :: boolean
  defp identical_frequency?(bit_frequency) do
    bit_frequency
    |> Enum.uniq_by(&get_frequency/1)
    |> length() == 1
  end

  defp get_frequency({_bit, frequency}), do: frequency

  @spec bin_to_int(list(bit)) :: integer
  defp bin_to_int(bits) do
    bits
    |> Enum.join()
    |> Integer.parse(2)
    |> elem(0)
  end
end

Program.solve()
