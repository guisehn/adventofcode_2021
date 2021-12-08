defmodule Program do
  def solve do
    input()
    |> get_last_parts()
    |> count_digits()
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

  defp get_last_parts(items) do
    items
    |> Enum.map(&List.last/1)
    |> List.flatten()
  end

  defp count_digits(signals) do
    #                                           1  4  7  8
    Enum.count(signals, &(String.length(&1) in [2, 4, 3, 7]))
  end
end

Program.solve()
