defmodule Program do
  @steps 10

  def solve do
    {template, rules} = input()

    element_freq =
      1..@steps
      |> Enum.reduce(template, fn _, polymer -> next_polymer(polymer, rules) end)
      |> String.graphemes()
      |> Enum.frequencies()

    least_common_element = element_freq |> Enum.min_by(fn {_, n} -> n end) |> elem(1)
    most_common_element = element_freq |> Enum.max_by(fn {_, n} -> n end) |> elem(1)

    IO.inspect(most_common_element - least_common_element)
  end

  defp input do
    [template, rules] =
      File.read!("input.txt")
      |> String.trim()
      |> String.split("\n\n")

    rules =
      rules
      |> String.split("\n")
      |> Enum.map(&String.split(&1, " -> "))
      |> Enum.into(%{}, &List.to_tuple/1)

    {template, rules}
  end

  defp next_polymer(polymer, rules) do
    [first_pair | remaining_pairs] =
      polymer
      |> String.graphemes()
      |> Enum.chunk_every(2, 1)
      |> Enum.filter(& length(&1) == 2)
      |> Enum.map(& Enum.join(&1, "") |> adjust_pair(rules))

    remaining_pairs = Enum.map(remaining_pairs, &remove_first_char/1)

    [first_pair | remaining_pairs]
    |> Enum.join("")
  end

  defp adjust_pair(pair, rules) do
    middle_element = Map.get(rules, pair)
    String.at(pair, 0) <> middle_element <> String.at(pair, 1)
  end

  defp remove_first_char(str) do
    String.slice(str, 1..String.length(str) - 1)
  end
end

Program.solve()
