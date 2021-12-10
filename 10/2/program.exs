defmodule Program do
  @chars %{")" => "(", "]" => "[", "}" => "{", ">" => "<"}
  @open_chars Map.values(@chars)
  @close_chars Map.keys(@chars)

  def solve do
    input()
    |> Stream.map(&check_line/1)
    |> Stream.filter(&incomplete?/1)
    |> Stream.map(&remaining_stack/1)
    |> Stream.map(&calculate_score/1)
    |> Enum.sort()
    |> middle()
    |> IO.inspect()
  end

  defp input do
    File.read!("input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end

  defp check_line(chars, stack \\ [])

  defp check_line([], stack) when length(stack) > 0, do: {:incomplete, stack}

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

  defp incomplete?({:incomplete, _}), do: true
  defp incomplete?(_), do: false

  defp remaining_stack({:incomplete, stack}), do: stack

  defp calculate_score(stack, score \\ 0)

  defp calculate_score([], score), do: score

  defp calculate_score([head | tail], score) do
    score = score * 5 + char_score(head)
    calculate_score(tail, score)
  end

  defp char_score("("), do: 1
  defp char_score("["), do: 2
  defp char_score("{"), do: 3
  defp char_score("<"), do: 4

  defp middle(list) do
    middle = ceil(length(list) / 2) - 1
    Enum.at(list, middle)
  end
end

Program.solve()
