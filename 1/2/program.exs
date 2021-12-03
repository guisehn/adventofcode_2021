defmodule AdventOfCode1 do
  def solve do
    input()
    |> make_sliding_windows()
    |> Enum.map(&sum_sliding_window/1)
    |> make_pairs()
    |> Enum.map(&compare_pair/1)
    |> Enum.count(& &1 == :increased)
    |> IO.inspect()
  end

  def input do
    File.read!("input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end

  def make_sliding_windows(list, windows \\ [])
  def make_sliding_windows([_, _], windows), do: Enum.reverse(windows)
  def make_sliding_windows([a, b, c | rest], windows), do:
    make_sliding_windows([b | [c | rest]], [{a, b, c} | windows])

  defp sum_sliding_window({a, b, c}), do: a + b + c

  def make_pairs(list, pairs \\ [])
  def make_pairs([_], pairs), do: Enum.reverse(pairs)
  def make_pairs([a, b | rest], pairs), do: make_pairs([b | rest], [{a, b} | pairs])

  def compare_pair({a, b}) when b > a, do: :increased
  def compare_pair({a, b}) when b < a, do: :decreased
  def compare_pair({_, _}), do: :no_change
end

AdventOfCode1.solve()
