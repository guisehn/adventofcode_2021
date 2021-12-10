defmodule Program do
  @chars %{")" => "(", "]" => "[", "}" => "{", ">" => "<"}
  @open_chars Map.values(@chars)
  @close_chars Map.keys(@chars)

  def solve do
    input()
    |> Stream.map(&check_line/1)
    |> Stream.filter(&illegal?/1)
    |> Stream.map(&illegal_char/1)
    |> Stream.map(&calculate_score/1)
    |> Enum.sum()
    |> IO.inspect()
  end

  defp input do
    File.read!("input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end

  defp check_line(chars, stack \\ [])

  defp check_line([], stack) when length(stack) > 0, do: :incomplete

  defp check_line([], _), do: :ok

  defp check_line([char | rest], stack) do
    case check_char(char, stack) do
      {:ok, stack} -> check_line(rest, stack)
      {:illegal, illegal_char} -> {:illegal, illegal_char}
    end
  end

  defp check_char(char, stack) when char in @open_chars, do: {:ok, [char | stack]}

  defp check_char(char, [stack_head | stack_rest]) when char in @close_chars do
    if Map.get(@chars, char) == stack_head do
      {:ok, stack_rest}
    else
      {:illegal, char}
    end
  end

  defp check_char(char, _), do: {:error, char}

  defp illegal?({:illegal, _}), do: true
  defp illegal?(_), do: false

  defp illegal_char({:illegal, char}), do: char

  defp calculate_score(")"), do: 3
  defp calculate_score("]"), do: 57
  defp calculate_score("}"), do: 1197
  defp calculate_score(">"), do: 25137
end

Program.solve()
