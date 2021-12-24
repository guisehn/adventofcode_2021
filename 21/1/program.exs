defmodule Dice do
  use Agent

  @initial_state %{num: 1, rolled: 0}

  def start_link() do
    Agent.start_link(fn -> @initial_state end, name: __MODULE__)
  end

  def roll do
    Agent.get_and_update(__MODULE__, fn %{num: num, rolled: rolled} ->
      {num, %{num: next(num), rolled: rolled + 1}}
    end)
  end

  def rolls do
    Agent.get(__MODULE__, fn %{rolled: rolled} -> rolled end)
  end

  defp next(n) when n == 100, do: 1
  defp next(n), do: n + 1
end

defmodule Player do
  defstruct [:id, :position, score: 0]

  @type t :: %Player{position: integer, score: integer}

  def play(%Player{position: position, score: score} = player) do
    numbers = for _ <- 1..3, do: Dice.roll()
    new_position = move(position, numbers)
    %Player{player | position: new_position, score: score + new_position}
  end

  def won?(%Player{score: score}) when score >= 1000, do: true
  def won?(_), do: false

  defp move(position, numbers) do
    case position + Enum.sum(numbers) do
      n when n > 10 ->
        rem = rem(n, 10)
        if rem == 0, do: 10, else: rem

      n -> n
    end
  end
end

defmodule Game do
  def play_until_end(players) do
    case play_round(players) do
      {:end_of_game, _winner, loser} ->
        Dice.rolls() * loser.score

      players ->
        play_until_end(players)
    end
  end

  def play_round(players, idx \\ 0)

  def play_round(players, idx) when idx == length(players) do
    players
  end

  def play_round(players, idx) do
    player = players |> Enum.at(idx) |> Player.play()

    if Player.won?(player) do
      end_of_game(player, players)
    else
      players
      |> List.replace_at(idx, player)
      |> play_round(idx + 1)
    end
  end

  defp end_of_game(winner, players) do
    loser = Enum.find(players, & &1.id != winner.id)
    {:end_of_game, winner, loser}
  end
end

defmodule Program do
  def solve do
    Dice.start_link()

    input()
    |> Game.play_until_end()
    |> IO.inspect()
  end

  defp input do
    File.read!("input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_input_player/1)
    |> Enum.with_index()
    |> Enum.map(fn {pos, idx} -> %Player{id: idx + 1, position: pos} end)
  end

  defp parse_input_player(line) do
    [_, pos] = Regex.run(~r/Player [0-9] starting position: ([0-9]+)/, line)
    String.to_integer(pos)
  end
end

Program.solve()
