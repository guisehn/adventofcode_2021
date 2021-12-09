defmodule Program do
  def solve do
    input()
    |> Enum.map(&solve/1)
    |> Enum.sum()
    |> IO.inspect()
  end

  defp input do
    File.read!("input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split("|")
      |> Enum.map(fn part ->
        part
        |> String.trim()
        |> String.split(" ")
      end)
    end)
  end

  defp solve([examples, digits]) do
    entry = Enum.map(examples, &str_to_set/1)

    n1 = Enum.find(entry, & MapSet.size(&1) == 2)
    n4 = Enum.find(entry, & MapSet.size(&1) == 4)
    n7 = Enum.find(entry, & MapSet.size(&1) == 3)
    n8 = Enum.find(entry, & MapSet.size(&1) == 7)
    n3 = Enum.find(entry, & MapSet.size(&1) == 5 && contains_segments?(&1, n1)) # |> inspect_set(label: "n3")
    n9 = Enum.find(entry, & MapSet.size(&1) == 6 && contains_segments?(&1, n4)) # |> inspect_set(label: "n9")
    n0 = Enum.find(entry, & MapSet.size(&1) == 6 && contains_segments?(&1, n7) && !contains_segments?(&1, n3)) # |> inspect_set(label: "n0")
    n6 = Enum.find(entry, & MapSet.size(&1) == 6 && &1 not in [n0, n9]) # |> inspect_set(label: "n6")
    n5 = Enum.find(entry, & MapSet.size(&1) == 5 && contains_segments?(n6, &1)) # |> inspect_set(label: "n5")
    n2 = Enum.find(entry, & MapSet.size(&1) == 5 && &1 not in [n3, n5]) # |> inspect_set(label: "n2")

    digits_map =
      [n0, n1, n2, n3, n4, n5, n6, n7, n8, n9]
      |> Enum.with_index()
      |> Map.new()

    digits
    |> Enum.map(& Map.get(digits_map, str_to_set(&1)))
    |> Enum.join("")
    |> String.to_integer()
  end

  defp str_to_set(str) do
    str
    |> String.graphemes()
    |> MapSet.new()
  end

  defp contains_segments?(a, b) do
    MapSet.intersection(a, b) == b
  end

  # defp inspect_set(set, opts \\ []) do
  #   set |> MapSet.to_list() |> Enum.join("") |> IO.inspect(opts)
  #   set
  # end
end

Program.solve()
