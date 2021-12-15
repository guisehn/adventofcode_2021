defmodule Program do
  @steps 40

  def solve do
    {template, rules} = input()

    polymer = split_pairs(template)
    rules = adjust_rules(rules)

    element_freq =
      1..@steps
      |> Enum.reduce(polymer, fn _, polymer -> next_polymer(polymer, rules) end)
      |> pairs_to_elements(template)

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

  defp split_pairs(template) do
    template
    |> String.graphemes()
    |> Enum.chunk_every(2, 1)
    |> Enum.filter(& length(&1) == 2)
    |> Enum.map(&Enum.join(&1, ""))
    |> Enum.frequencies()
  end

  defp adjust_rules(rules) do
    rules
    |> Enum.map(fn {k, v} -> {k, [String.at(k, 0) <> v, v <> String.at(k, 1)]} end)
    |> Enum.into(%{})
  end

  defp next_polymer(polymer, rules) do
    Enum.reduce(polymer, %{}, fn {pair, count}, polymer ->
      [pair1, pair2] = Map.get(rules, pair)

      polymer
      |> increment_key(pair1, count)
      |> increment_key(pair2, count)
    end)
  end

  defp pairs_to_elements(pairs, template) do
    Enum.reduce(pairs, %{}, fn {pair, count}, acc ->
      Map.update(acc, String.at(pair, 0), count, &(&1 + count))
    end)
    |> increment_key(String.last(template))
  end

  defp increment_key(map, key, value \\ 1), do:
    Map.update(map, key, value, &(&1 + value))
end

Program.solve()
