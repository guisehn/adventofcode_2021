Mix.install([{:struct_access, "~> 1.1.2"}])

defmodule Player do
  defstruct [:id, :position, score: 0]

  @type t :: %Player{id: id, position: integer, score: integer}
  @type id :: integer

  @dice_rolls for a <- 1..3, b <- 1..3, c <- 1..3, do: a + b + c

  def play(%Player{position: position, score: score} = player) do
    Enum.map(@dice_rolls, fn rolls_sum ->
      new_position = move(position, rolls_sum)
      %Player{player | position: new_position, score: score + new_position}
    end)
  end

  def won?(%Player{score: score}) when score >= 21, do: true
  def won?(_), do: false

  defp move(position, amount) do
    case rem(position + amount, 10) do
      0 -> 10
      n -> n
    end
  end
end

defmodule Game do
  defstruct [:players, :winner]

  @type t :: %Game{players: list(Player.t), winner: Player.id}

  @spec new(list(Player.t)) :: t
  def new(players), do: %Game{players: players}

  @spec finished?(t) :: boolean
  def finished?(game), do: game.winner != nil

  @spec play_round(t) :: list(t)
  def play_round(game, idx \\ 0)

  def play_round(%Game{players: players} = game, idx) when idx == length(players) do
    game
  end

  def play_round(%Game{players: players}, idx) do
    players
    |> Enum.at(idx)
    |> Player.play()
    |> Enum.map(fn player ->
      players = List.replace_at(players, idx, player)
      game = %Game{players: players}

      if Player.won?(player) do
        %{game | winner: player.id}
      else
        play_round(game, idx + 1)
      end
    end)
    |> List.flatten()
  end
end

defmodule GamesCount do
  use StructAccess

  defstruct [pending: %{}, finished: %{}]

  @type t :: %{pending: count, finished: count}
  @type count :: %{Game.t => integer}

  @spec new(Game.t) :: t
  def new(game) do
    %GamesCount{pending: Map.put(%{}, game, 1), finished: %{}}
  end

  @spec expand(t) :: t
  def expand(games_count, i \\ 1)

  def expand(%GamesCount{pending: pending, finished: finished}, _) when map_size(pending) == 0,
    do: finished

  def expand(games_count, i) do
    IO.puts("Calculating round #{i}...")

    games_count
    |> generate_subgames()
    |> expand(i + 1)
  end

  defp generate_subgames(%GamesCount{pending: pending, finished: finished}) do
    pending
    |> Enum.reduce(%GamesCount{finished: finished}, fn {game, count}, new_games ->
      Game.play_round(game)
      |> Enum.frequencies()
      |> Enum.reduce(new_games, fn {subgame, subcount}, new_games ->
        submap = if Game.finished?(subgame), do: :finished, else: :pending
        amount = count * subcount
        update_in(new_games, [submap, subgame], &((&1 || 0) + amount))
      end)
    end)
  end

  @spec count_wins(t) :: %{Player.id => integer}
  def count_wins(games_count) do
    games_count
    |> Enum.group_by(fn {%Game{winner: winner}, _} -> winner end)
    |> Enum.map(fn {player, games} ->
      count = Enum.map(games, fn {_, count} -> count end) |> Enum.sum()
      {player, count}
    end)
    |> Enum.into(%{})
  end
end

defmodule Program do
  def solve do
    input()
    |> GamesCount.expand()
    |> GamesCount.count_wins()
    |> IO.inspect(label: "Wins per player")
  end

  defp input do
    File.read!("input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_input_player/1)
    |> Enum.with_index()
    |> Enum.map(fn {pos, idx} -> %Player{id: idx + 1, position: pos} end)
    |> Game.new()
    |> GamesCount.new()
  end

  defp parse_input_player(line) do
    [_, pos] = Regex.run(~r/Player [0-9] starting position: ([0-9]+)/, line)
    String.to_integer(pos)
  end
end

Program.solve()
