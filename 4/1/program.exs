defmodule Board do
  @type t :: %Board{matrix: matrix}
  @type matrix :: list(list(board_num))
  @type board_num :: {integer, marked}
  @type marked :: boolean

  defstruct [:matrix]

  @spec new(list(String.t())) :: Board.t()
  def new(lines) do
    matrix = Enum.map(lines, &parse_line/1)
    %Board{matrix: matrix}
  end

  defp parse_line(line) do
    line
    |> String.trim()
    |> String.split(~r/\s+/)
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(& {&1, false})
  end

  @spec mark_number(Board.t(), integer) :: Board.t()
  def mark_number(%Board{matrix: matrix} = board, number) do
    matrix =
      matrix
      |> Enum.map(fn line ->
        Enum.map(line, fn {n, marked?} ->
          {n, if(n == number, do: true, else: marked?)}
        end)
      end)

    %{board | matrix: matrix}
  end

  @spec won?(Board.t()) :: boolean
  def won?(%Board{matrix: matrix}) do
    completed_any_row?(matrix) || completed_any_column?(matrix)
  end

  def unmarked_numbers(%Board{matrix: matrix}) do
    matrix
    |> Enum.map(fn line ->
      line
      |> Enum.filter(fn {_n, marked?} -> !marked? end)
      |> Enum.map(fn {n, _marked?} -> n end)
    end)
    |> List.flatten()
  end

  defp completed_any_row?(matrix), do: Enum.any?(matrix, &completed_row?/1)
  defp completed_row?(row), do: Enum.all?(row, fn {_n, marked?} -> marked? end)

  defp completed_any_column?(matrix), do: matrix |> transpose() |> completed_any_row?()
  defp transpose(matrix), do: matrix |> List.zip() |> Enum.map(&Tuple.to_list/1)
end

defmodule InputParser do
  @board_rows 5

  def parse(input) do
    {get_numbers(input), get_boards(input)}
  end

  defp get_numbers([numbers | _]) do
    numbers
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp get_boards([_numbers, _ | lines]) do
    lines
    |> Kernel.++([""])
    |> Enum.chunk_every(@board_rows + 1)
    |> Enum.map(&remove_last_element/1)
    |> Enum.map(&Board.new/1)
  end

  defp remove_last_element(list) do
    list
    |> List.pop_at(-1)
    |> elem(1)
  end
end

defmodule Program do
  def solve do
    {numbers, boards} = input() |> InputParser.parse()

    case play_round(numbers, boards) do
      {board, last_number} ->
        unmarked_sum = board |> Board.unmarked_numbers() |> Enum.sum()
        result = unmarked_sum * last_number
        IO.inspect(result)

      _ ->
        IO.puts("no winner")
    end
  end

  defp input do
    File.read!("input.txt")
    |> String.trim()
    |> String.split("\n")
  end

  defp play_round([], _), do: nil
  # defp play_round([], boards), do: boards

  defp play_round([number | rest], boards) do
    boards = Enum.map(boards, &Board.mark_number(&1, number))
    winner = Enum.find(boards, &Board.won?/1)

    case winner do
      %Board{} = board -> {board, number}
      nil -> play_round(rest, boards)
    end
  end
end

Program.solve()
