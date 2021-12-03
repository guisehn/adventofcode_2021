defmodule AdventOfCode1 do
  def solve do
    input()
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

  def make_pairs(list, pairs \\ [])
  def make_pairs([_], pairs), do: Enum.reverse(pairs)
  def make_pairs([a, b | rest], pairs), do: make_pairs([b | rest], [{a, b} | pairs])

  def compare_pair({a, b}) when b > a, do: :increased
  def compare_pair({_, _}), do: :decreased
end

AdventOfCode1.solve()
